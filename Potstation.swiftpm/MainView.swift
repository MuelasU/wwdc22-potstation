import SwiftUI
import SceneKit

struct MainView: View {
    @Binding var vase: Vase
    @Binding var onboarding: Bool
    
    @State var isFirstDraw: Bool = true
    
    let navigate: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .center) {
                    VaseSceneView(vase: $vase)
                    
                    HStack {
                        Image("left")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                        
                        Spacer()
                        
                        Image("right")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                }
                
                VStack {
                    if onboarding {
                        onboardingView
                    } else {
                        editView
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height * 0.6)
                .background(
                    Image("desk")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                )
                .clipped()
            }.background(Color.green)
        }
        .edgesIgnoringSafeArea(.all)
        .frame(maxHeight: .infinity)
    }
    
    var editView: some View {
        GeometryReader { geometry in
            HStack(spacing: 30) {
                VStack {
                    Text("Customization")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    VStack {
                        ColorPicker(selection: $vase.mainColor) {
                            Text("Vase color")
                                .font(.title2)
                        }
                        
                        ColorPicker(selection: $vase.patternColor) {
                            Text("Pattern color")
                                .font(.title2)
                        }
                    }
                    
                    Spacer()
                    
                    HStack {
                        Text("Choose a pattern")
                            .font(.title)
                            .fontWeight(.semibold)
                        
                        Spacer()
                    }
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ]) {
                        ForEach(Vase.Pattern.allCases, id: \.self) { pattern in
                            Button(action: {
                                vase.pattern = pattern
                            }, label: {
                                Image(uiImage: UIImage.pattern(pattern, backColor: .init(gray: 1, alpha: 0.6), topColor: .init(gray: 0, alpha: 1))!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .cornerRadius(10)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(
                                                vase.pattern == pattern ? Color(red: 211/255, green: 90/255, blue: 22/255) : Color(red: 66/255, green: 28/255, blue: 7/255),
                                                lineWidth: 5)
                                    }
                                    
                            })
                            .padding(3)
                        }
                    }
                    
                    Spacer()
                    Spacer()
                    
                    Button(action: navigate) {
                        HStack {
                            Text("See in World!")
                                .fontWeight(.medium)
                            Text(Image(systemName: "arkit"))
                                .fontWeight(.medium)
                        }
                        .font(.title2)
                        .foregroundColor(vase.isEmpty ? .init(.sRGB, white: 1, opacity: 0.25) : .white)
                        .background(vase.isEmpty ? Image("button-disabled") : Image("button"))
                    }
                    .disabled(vase.isEmpty)
                    .padding()
                    
                    Spacer()
                }
                .foregroundColor(.init(.sRGB, white: 0.85, opacity: 1))
                .frame(maxWidth: geometry.size.width * 0.4)
                .padding(20)
                
                ZStack(alignment: .topLeading) {
                    CanvasView(started: {
                        isFirstDraw = false
                    }, finished: { draw in
                        let pattern = vase.pattern
                        let mainColor = vase.mainColor
                        let patternColor = vase.patternColor
                        vase = .init(draw: draw.cgPath)
                        vase.pattern = pattern
                        vase.mainColor = mainColor
                        vase.patternColor = patternColor
                    })
                    .background(Color.white)
                    .offset(x: 45, y: 75)
                    .overlay {
                        if isFirstDraw {
                            Image("draw-instructions")
                                .offset(x: 30, y: 50)
                        }
                    }
                    
                    Image("clipboard-up")
                        .offset(x: 200, y: -41)
                }
                .background(Color(red: 185/255, green: 119/255, blue: 58/255))
                .padding(.top, 60)
            }
        }
    }
    
    var onboardingView: some View {
        VStack(alignment: .center) {
            Image("heading")
                                 
            Text("Pottery started being made so many time ago mainly for utilitarian, when we were still \"cave” people. As time passes, this activity has been enhanced as a symbol of different cultures and nowadays it is an important form of art that can be made by anyone. How about try it now?")
                .font(.title2)
                .foregroundColor(.init(white: 0.85))
                .padding(.vertical, 50)
            
            Button(action: {
                onboarding = false
            }) {
                HStack {
                    Text("Start Pottery")
                        .fontWeight(.medium)
                    Text(Image(systemName: "play"))
                        .fontWeight(.medium)
                }
                .font(.title2)
                .foregroundColor(.white)
                .padding()
                .background(Image("button"))
            }
        }
        .padding(EdgeInsets(top: 40, leading: 100, bottom: 60, trailing: 100))
    }
}
