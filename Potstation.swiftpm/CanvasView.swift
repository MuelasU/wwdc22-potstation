//
//  File.swift
//  wwdc22
//
//  Created by Gabriel Muelas on 14/04/22.
//

import SwiftUI

struct CanvasView: View {
    @State private var currentLine: [CGPoint] = []
    @State private var lastLine: [CGPoint] = [] {
        didSet {
            finishedHandler(Path { path in
                path.addLines(lastLine)
            })
        }
    }
    @State private var isDrawing: Bool = false
    
    private let startedHandler: () -> Void
    private let finishedHandler: (Path) -> Void
    
    var body: some View {
        Canvas { context, size in
            var path = Path()
            path.addLines(isDrawing ? currentLine : lastLine)
            context.stroke(
                path,
                with: .color(.blue),
                lineWidth: 4
            )
        }
        .gesture(
            DragGesture(minimumDistance: 1)
            .onChanged { value in
                isDrawing = true
                startedHandler()
                let point = value.location
                currentLine.append(point)
            }
            .onEnded { value in
                lastLine = currentLine
                currentLine = .init()
                isDrawing = false
            }
        )
    }
    
    init(started startHandler: @escaping () -> Void, finished finishHandler: @escaping (Path) -> Void) {
        self.startedHandler = startHandler
        self.finishedHandler = finishHandler
    }
}
