import UIKit

extension UIView {

  func resetToVisible() {
    transform = .identity
    alpha = 1
    isHidden = false
  }

}

extension UIView {
  func currentFirstResponder() -> UIResponder? {
    if isFirstResponder{
      return self
    }

    for view in subviews {
      if let responder = view.currentFirstResponder() {
        return responder
      }
    }

    return nil
  }
}
