import UIKit

extension UIImage {
    
    public func resize(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    public func resize(by scale: CGFloat) -> UIImage {
        guard scale > 0 else { return self } // 잘못된 배율 방지
        let newSize = CGSize(width: self.size.width * scale, height: self.size.height * scale)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
