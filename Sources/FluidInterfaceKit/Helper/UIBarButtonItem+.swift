
import UIKit

extension UIBarButtonItem {
  
  static func _fluid_chevronBackward() -> Self {
    if #available(iOS 13.0, *) {
      let image = UIImage(systemName: "chevron.backward")
      return .init(image: image, style: .plain, target: nil, action: nil)
    } else {
      return .init(barButtonSystemItem: .init(rawValue: 101)!, target: nil, action: nil)
    }
    
  }
  
  static func _fluid_multiply() -> Self {
    if #available(iOS 13.0, *) {
      let image = UIImage(systemName: "multiply")
      return .init(image: image, style: .plain, target: nil, action: nil)
    } else {
      return .init(barButtonSystemItem: .stop, target: nil, action: nil)
    }
    
  }
  
}
