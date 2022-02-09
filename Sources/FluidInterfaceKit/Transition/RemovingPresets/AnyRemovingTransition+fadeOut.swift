import UIKit

extension AnyRemovingTransition {

  public static func fadeOut(
    duration: TimeInterval = 0.6
  ) -> Self {

    return .init { context in

      context.contentView.backgroundColor = .clear

      let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
        context.fromViewController.view.alpha = 0
      }

      animator.addCompletion { _ in
        context.notifyAnimationCompleted()
      }

      animator.startAnimation()

    }

  }

}
