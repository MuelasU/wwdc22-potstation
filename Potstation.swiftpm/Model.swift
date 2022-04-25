//
//  File.swift
//  wwdc22
//
//  Created by Gabriel Muelas on 14/04/22.
//

import Euclid
import CoreGraphics
import SceneKit

struct Vase {
    var mainColor: CGColor = UIColor.brown.cgColor
    var patternColor: CGColor = UIColor.black.cgColor
    var pattern: Pattern = .none
    
    var node: SCNNode {
        let geometry = SCNGeometry(mesh)
        return SCNNode(geometry: geometry)
    }
    
    var isEmpty: Bool {
        draw.paths().first?.points.isEmpty ?? true
    }
    
    private var draw: CGPath
    private var scale: Double {
        0.002
    }
    private var texture: Mesh.Material {
        UIImage.pattern(pattern, backColor: mainColor, topColor: patternColor)?.rotate(radians: .pi)
    }
    
    // moves the draw to Y axis
    private var drawInY: CGPath {
        let bezier = UIBezierPath(cgPath: draw)
        let dx = bezier.bounds.minX * -1
        bezier.apply(.init(translationX: dx, y: 0))
        return bezier.cgPath
    }
    
    private var mesh: Mesh {
        // revolve draw around Y axis
        var mesh = Mesh.lathe(
            Path(drawInY),
            slices: 24,
            material: texture
        )
        // positioning the mesh accordingly
        mesh = mesh.translated(by: .init(0, -1 * mesh.bounds.min.y, 0))
        mesh = mesh.rotated(by: .roll(.pi))
        mesh = mesh.translated(by: .init(0, -1 * mesh.bounds.min.y, 0))
        mesh = mesh.scaled(by: scale)
        return mesh
    }
    
    init(draw: CGPath) {
        self.draw = draw
    }
    
    enum Pattern: String, CaseIterable {
        case none
        case zigzag
        case quadratic
        case plus
        case cracked
        case dots
    }
}
