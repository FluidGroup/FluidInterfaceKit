
import UIKit

extension UIBarButtonItem {
  
  public static func _fluid_backButton() -> Self {
    if #available(iOS 13.0, *) {
      let image = UIImage(systemName: "chevron.backward")
      return .init(image: image, style: .plain, target: nil, action: nil)
    } else {
      return .init(barButtonSystemItem: .init(rawValue: 101)!, target: nil, action: nil)
    }
    
  }
  
}
