import SwiftUI

struct ARViewIndicator: UIViewControllerRepresentable {
    typealias UIViewControllerType = ARViewController
    
    @Binding var vase: Vase
    @Binding var willTakePicture: Bool
    let planeDetected: Binding<Bool>
    let positionDefined: Binding<Bool>
    let picture: Binding<UIImage?>
        
    class Coordinator: ARViewControllerDelegate {
        let isPlaneDetected: Binding<Bool>
        let isPositionDefined: Binding<Bool>
        let pictureTaken: Binding<UIImage?>
        
        init(isPlaneDetected: Binding<Bool>, isPositionDefined: Binding<Bool>, pictureTaken: Binding<UIImage?>) {
            self.isPlaneDetected = isPlaneDetected
            self.isPositionDefined = isPositionDefined
            self.pictureTaken = pictureTaken
        }
        
        func planeDetected() {
            isPlaneDetected.wrappedValue = true
        }
        
        func positionDefined() {
            isPositionDefined.wrappedValue = true
        }
        
        func pictureTaken(_ picture: UIImage) {
            pictureTaken.wrappedValue = picture
        }
    }
    
    func makeUIViewController(context: Context) -> ARViewController {
        let vc = ARViewController()
        vc.delegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: ARViewController, context: Context) {
        uiViewController.vase = vase
        if willTakePicture {
            DispatchQueue.main.async {
                uiViewController.takePicture()
                willTakePicture = false
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isPlaneDetected: planeDetected, isPositionDefined: positionDefined, pictureTaken: picture)
    }
}
