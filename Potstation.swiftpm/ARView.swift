//
//  File.swift
//  wwdc22
//
//  Created by Gabriel Muelas on 18/04/22.
//

import Foundation
import UIKit
import ARKit
import SwiftUI

protocol ARViewControllerDelegate: AnyObject {
    func planeDetected()
    func positionDefined()
}

class ARViewController: UIViewController, ARSCNViewDelegate {
    weak var delegate: ARViewControllerDelegate?
    
    var scene = SCNScene()
    var vase: Vase? {
        didSet {
            updateNode()
        }
    }
    var position: SCNVector3? {
        didSet {
            updateNode()
            delegate?.positionDefined()
        }
    }
    
    var arView: ARSCNView {
        return view as! ARSCNView
    }
    
    func updateNode() {
        if let existingNode = scene.rootNode.childNode(withName: "vase", recursively: false) {
            existingNode.removeFromParentNode()
        }
        
        if let node = vase?.node, let position = position {
            node.position = position
            node.name = "vase"
            scene.rootNode.addChildNode(node)
        }
    }
    
    @objc func definePosition(sender: UITapGestureRecognizer) {
        let location = sender.location(in: arView)
        
        guard
            let query = arView.raycastQuery(from: location, allowing: .existingPlaneGeometry, alignment: .any),
            let result = arView.session.raycast(query).first
        else {
            print("No plane detected")
            return
        }
        
        let columns = result.worldTransform.columns.3
        position = .init(columns.x, columns.y, columns.z)
    }
    
    override func loadView() {
        view = ARSCNView(frame: .zero)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arView.delegate = self
        arView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        UIApplication.shared.isIdleTimerDisabled = true
        arView.autoenablesDefaultLighting = true
        arView.session.run(configuration)
        arView.delegate = self
        
        
        arView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(definePosition(sender:)))
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        delegate?.planeDetected()
        
        guard
            let planeAnchor = anchor as? ARPlaneAnchor,
            let geometry = ARSCNPlaneGeometry(device: arView.device!)
        else {
            return
        }

        // Create node
        geometry.update(from: planeAnchor.geometry)
        let planeNode = SCNNode(geometry: geometry)
        planeNode.name = "plane"
        guard let material = planeNode.geometry?.firstMaterial else { return }
        material.diffuse.contents = UIColor(white: 1, alpha: 0.2)
        material.blendMode = .add

        node.addChildNode(planeNode)
  }
  
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard
            let planeAnchor = anchor as? ARPlaneAnchor,
            let geometry = node.childNode(withName: "plane", recursively: false)?.geometry as? ARSCNPlaneGeometry
        else {
            return
        }

        geometry.update(from: planeAnchor.geometry)
    }
}

struct ARViewIndicator: UIViewControllerRepresentable {
    typealias UIViewControllerType = ARViewController
    
    @Binding var vase: Vase
    let planeDetected: Binding<Bool>
    let positionDefined: Binding<Bool>
        
    class Coordinator: ARViewControllerDelegate {
        let isPlaneDetected: Binding<Bool>
        let isPositionDefined: Binding<Bool>
        
        init(isPlaneDetected: Binding<Bool>, isPositionDefined: Binding<Bool>) {
            self.isPlaneDetected = isPlaneDetected
            self.isPositionDefined = isPositionDefined
        }
        
        func planeDetected() {
            isPlaneDetected.wrappedValue = true
        }
        
        func positionDefined() {
            isPositionDefined.wrappedValue = true
        }
    }
    
    func makeUIViewController(context: Context) -> ARViewController {
        let vc = ARViewController()
        vc.delegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: ARViewController, context: Context) {
        uiViewController.vase = vase
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isPlaneDetected: planeDetected, isPositionDefined: positionDefined)
    }
}

struct ARView: View {
    @Binding var vase: Vase
    @State var planeDetected: Bool = false
    @State var positionDefined: Bool = false
    
    let navigate: () -> Void
    
    var body: some View {
        ARViewIndicator(vase: $vase, planeDetected: $planeDetected, positionDefined: $positionDefined)
            .edgesIgnoringSafeArea(.all)
            .overlay {
                ZStack {
                    VStack {
                        Spacer()
                        
                        if planeDetected && !positionDefined {
                            Text ("Touch on plane to place your pot")
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding()
                        }
                        
                        Button(action: navigate) {
                            Text("Done")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(EdgeInsets(top: 10, leading: 30, bottom: 10, trailing: 30))
                                .background(
                                    Capsule()
                                        .fill(Color.init(red: 211/255, green: 90/255, blue: 22/255))
                                )
                                .padding()
                        }
                    }
                    .padding()
                    
                    if !planeDetected {
                        VStack {
                            ProgressView()
                                .tint(.white)
                                .padding()
                            
                            Text ("Detecting planes. Scan the space to help")
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .foregroundColor(.white)
                        .background(Color(.sRGB, white: 0.7, opacity: 0.4))
                    }
                }
            }
    }
}
