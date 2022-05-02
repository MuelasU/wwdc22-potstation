import UIKit
import ARKit

protocol ARViewControllerDelegate: AnyObject {
    func planeDetected()
    func positionDefined()
    func pictureTaken(_ picture: UIImage)
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
    
    func takePicture() {
        let snapshot = self.arView.snapshot()
        self.delegate?.pictureTaken(snapshot)
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
