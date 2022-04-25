import SwiftUI
import SceneKit
import ARKit

enum Page {
    case mainView
    case arView
}

struct ContentView: View {
    @State var vase: Vase = .init(draw: Path().cgPath)
    @State var displayingView: Page = .mainView
    @State var onboarding = true
    
    var body: some View {
        switch displayingView {
        case .mainView:
            MainView(vase: $vase, onboarding: $onboarding, navigate: { displayingView = .arView })
        case .arView:
            ARView(vase: $vase, navigate: { displayingView = .mainView })
        }
        
    }
}
