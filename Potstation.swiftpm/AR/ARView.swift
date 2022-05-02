import SwiftUI

struct ARView: View {
    @Binding var vase: Vase
    @State var picture: UIImage? = nil
    @State var planeDetected: Bool = false
    @State var positionDefined: Bool = false
    @State var willTakePicture: Bool = false
    @State var showPlanes: Bool = true
    
    let navigate: () -> Void
    
    var body: some View {
        ARViewIndicator(vase: $vase, willTakePicture: $willTakePicture, planeDetected: $planeDetected, positionDefined: $positionDefined, picture: $picture)
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
                        
                        HStack(spacing: 50) {
                            Button(action: navigate) {
                                Image(systemName: "chevron.left")
                                    .font(Font.title.weight(.semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 60)
                            }
                            
                            Button(action: { willTakePicture = true }) {
                                Circle()
                                    .fill(Color.white.opacity(0.000001))
                                    .padding()
                                    .frame(width: 70, height: 70)
                                    .background(
                                        Circle()
                                            .strokeBorder(.white, lineWidth: 7)
                                    )
                            }
                            
                            Button(action: { showPlanes.toggle() }) {
                                Image(showPlanes ? "unsee-icon" : "see-icon")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50)
                            }
                        }
                        
                    }
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 0)
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
                    
                    if let picture = picture {
                        GeometryReader { geometry in
                            VStack {
                                Spacer()
                                
                                Image(uiImage: picture)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: geometry.size.height * 0.8)
                                    .padding()
                                    .padding(.bottom, 30)
                                    .background(Color.white.shadow(radius: 10))
                                    
                                
                                Spacer()
                            }
                            .frame(width: geometry.size.width)
                        }
                        .background(.ultraThinMaterial)
                        .edgesIgnoringSafeArea(.all)
                        
                    }
                }
            }
    }
}
