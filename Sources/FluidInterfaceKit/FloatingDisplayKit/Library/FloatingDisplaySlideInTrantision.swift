import UIKit

@available(*, deprecated, renamed: "FloatingDisplaySlideInTrantision")
public typealias SnackbarAnimator = FloatingDisplaySlideInTrantision

public struct FloatingDisplaySlideInTrantision: FloatingDisplayTransitionType {

  public init() {
  }

  public func applyPresentAnimation(
    notificationView: FloatingDisplayViewType,
    completion: @escaping () -> Void
  ) {

    notificationView.alpha = 0
    notificationView.transform = CGAffineTransform(
      translationX: 0,
      y: -notificationView.bounds.height
    )

    let animator = UIViewPropertyAnimator(duration: 0.4, dampingRatio: 0.8) {
      notificationView.transform = .identity
      notificationView.alpha = 1
    }

    animator.addCompletion { _ in
      completion()
    }

    animator.startAnimation()

  }

  public func applyDismissAnimation(
    notificationView: FloatingDisplayViewType,
    completion: @escaping () -> Void
  ) {

    let animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 1) {
      notificationView.transform = notificationView.transform.translatedBy(
        x: 0,
        y: -notificationView.bounds.height
      )
      notificationView.alpha = 0

    }

    animator.addCompletion { _ in
      completion()
    }

    animator.startAnimation()

  }
}

public struct FloatingDisplayFloatUpTrantision: FloatingDisplayTransitionType {

  public init() {
  }

  public func applyPresentAnimation(
    notificationView: FloatingDisplayViewType,
    completion: @escaping () -> Void
  ) {

    notificationView.alpha = 0
    notificationView.transform = CGAffineTransform(
      translationX: 0,
      y: notificationView.bounds.height
    )

    let animator = UIViewPropertyAnimator(duration: 0.4, dampingRatio: 0.8) {
      notificationView.transform = .identity
      notificationView.alpha = 1
    }

    animator.addCompletion { _ in
      completion()
    }

    animator.startAnimation()

  }

  public func applyDismissAnimation(
    notificationView: FloatingDisplayViewType,
    completion: @escaping () -> Void
  ) {

    let animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 1) {
      notificationView.transform = notificationView.transform.translatedBy(
        x: 0,
        y: notificationView.bounds.height
      )
      notificationView.alpha = 0

    }

    animator.addCompletion { _ in
      completion()
    }

    animator.startAnimation()

  }
}
