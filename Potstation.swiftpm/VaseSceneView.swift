import SceneKit
import SwiftUI

struct VaseSceneView: View {
    @Binding var vase: Vase
    
    var camera: SCNNode {
        let camera = SCNCamera()
        let cameraNode = SCNNode()
        cameraNode.position = .init(1, 1, 2)
        let angle = CGFloat.pi / -6
        cameraNode.eulerAngles = .init(angle, 0, 0)
        cameraNode.camera = camera
        let lookConstraint = SCNLookAtConstraint(target: vase.node)
        lookConstraint.isGimbalLockEnabled = true
        cameraNode.constraints = [lookConstraint]
        return cameraNode
    }
    
    var desk: SCNNode {
        var geometry = SCNCylinder(radius: 0.4, height: 2)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red: 84/255, green: 53/255, blue: 7/255, alpha: 1)
        geometry.materials = [material]
        let baseNode = SCNNode(geometry: geometry)
        baseNode.position = .init(0, -1, 0)
        
        geometry = SCNCylinder(radius: 0.8, height: 0.05)
        geometry.materials = [material]
        let topNode = SCNNode(geometry: geometry)
        baseNode.addChildNode(topNode)
        topNode.position = .init(0, 1, 0)
        
        return baseNode
    }
    
    var lights: [SCNNode] {
        let nodes: [SCNNode] = (1...3).map { _ in
            let light = SCNLight()
            light.intensity = 1000
            light.type = .directional
            light.castsShadow = true
            light.shadowRadius = 15
            light.shadowColor = UIColor(white: 0, alpha: 0.2)
            let node = SCNNode()
            node.light = light
            let lookConstraint = SCNLookAtConstraint(target: vase.node)
            lookConstraint.isGimbalLockEnabled = true
            node.constraints = [lookConstraint]
            return node
        }
        nodes[0].position = .init(2, 1, 2)
        nodes[1].position = .init(-2, 1, 2)
        nodes[2].position = .init(2, 1, -2)
        
        nodes[0].light!.intensity = 500
        return nodes
    }
    
    var floor: SCNNode {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red: 132/255, green: 151/255, blue: 123/255, alpha: 1)
        let floor = SCNFloor()
        floor.materials = [material]
        let floorNode = SCNNode(geometry: floor)
        floorNode.position = .init(0, -2, 0)
        return floorNode
    }
        
    var scene: SCNScene {
        let scene = SCNScene()
        scene.background.contents = UIColor(red: 195/255, green: 167/255, blue: 125/255, alpha: 1)
        scene.rootNode.addChildNode(floor)
        scene.rootNode.addChildNode(camera)
        scene.rootNode.addChildNode(desk)
        scene.rootNode.addChildNode(vase.node)
        lights.forEach { light in
            scene.rootNode.addChildNode(light)
        }
        return scene
    }
    
    var body: some View {
        SceneView(
            scene: scene,
            options: [
                .autoenablesDefaultLighting,
                .allowsCameraControl
            ]
        )
    }
}
