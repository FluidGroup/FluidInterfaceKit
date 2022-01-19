
import UIKit

extension UIView {

  func resetToVisible() {
    transform = .identity
    alpha = 1
    isHidden = false
  }

}
