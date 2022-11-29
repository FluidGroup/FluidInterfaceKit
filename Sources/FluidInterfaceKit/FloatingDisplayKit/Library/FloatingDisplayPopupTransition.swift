
import UIKit

public struct FloatingDisplayPopupTransition: FloatingDisplayTransitionType {

  public init() {
  }

  public func applyPresentAnimation(notificationView: FloatingDisplayViewType, completion: @escaping () -> Void) {

    notificationView.alpha = 0
    notificationView.transform = .init(scaleX: 1.1, y: 1.1)

    let animator = UIViewPropertyAnimator(duration: 0.6, dampingRatio: 0.9) {
      notificationView.transform = .identity
      notificationView.alpha = 1
    }

    animator.addCompletion { _ in
      completion()
    }

    animator.startAnimation()

  }

  public func applyDismissAnimation(notificationView: FloatingDisplayViewType, completion: @escaping () -> Void) {

    let animator = UIViewPropertyAnimator(duration: 0.4, dampingRatio: 1) {
      notificationView.transform = .init(scaleX: 1.1, y: 1.1)
      notificationView.alpha = 0
    }

    animator.addCompletion { _ in
      completion()
    }

    animator.startAnimation()
  }
}
