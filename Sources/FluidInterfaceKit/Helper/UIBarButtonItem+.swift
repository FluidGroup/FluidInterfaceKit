
import UIKit

extension UIBarButtonItem {
  
  static func backButton() -> Self {
    .init(barButtonSystemItem: .init(rawValue: 101)!, target: nil, action: nil)    
  }
  
}
