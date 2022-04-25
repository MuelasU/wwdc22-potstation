import UIKit
import SceneKit

extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        context.rotate(by: CGFloat(radians))
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
    
    static func pattern(_ pattern: Vase.Pattern, backColor bgColor: CGColor, topColor pColor: CGColor) -> UIImage? {
        
        let size = CGSize(width: 800, height: 500)
        let rect = CGRect(origin: .zero, size: size)
        let renderer = UIGraphicsImageRenderer(size: size)

        let bgColor = UIColor(cgColor: bgColor)
        let pColor = UIColor(cgColor: pColor)
        
        let bgImage = renderer.image { context in
            bgColor.set()
            context.fill(rect)
        }

        guard pattern != .none else {
            return bgImage
        }
        let patternImage = UIImage(named: pattern.rawValue)!
        let topImage = patternImage.withTintColor(pColor)

        UIGraphicsBeginImageContext(size)
        bgImage.draw(in: rect)
        topImage.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    
}
