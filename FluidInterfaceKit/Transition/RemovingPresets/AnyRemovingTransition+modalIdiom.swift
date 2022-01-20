import UIKit

extension AnyRemovingTransition {

  public static func modalIdiom(
    duration: TimeInterval = 0.6
  ) -> Self {

    return .init { context in

      let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {

        context.fromViewController.view.transform = .init(
          translationX: 0,
          y: context.fromViewController.view.bounds.height
        )
        context.fromViewController.view.alpha = 1
      }

      animator.addCompletion { _ in
        context.notifyCompleted()
      }

      animator.startAnimation()

    }

  }

}
