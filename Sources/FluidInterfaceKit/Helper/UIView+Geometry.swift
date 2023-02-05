
import UIKit

extension UIView {
  
  /// A rect of view without transform
  var frameAsIdentity: CGRect {
    
    CGRect(origin: .init(x: center.x - (bounds.width / 2), y: center.y - (bounds.height / 2)), size: bounds.size)
    
  }
}

