
import CoreGraphics

extension CGVector {
  
  var magnitude: CGFloat {
    sqrt(pow(dx, 2) + pow(dy, 2))
  }
  
}
