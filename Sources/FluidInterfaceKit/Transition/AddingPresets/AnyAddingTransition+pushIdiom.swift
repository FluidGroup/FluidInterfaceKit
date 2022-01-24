import UIKit

extension AnyAddingTransition {

  public static func pushIdiom(
    duration: TimeInterval = 0.6
  ) -> Self {

    return .init { context in
     
      context.toViewController.view.transform = .init(translationX: context.toViewController.view.bounds.width, y: 0)
      context.toViewController.view.alpha = 0.02

      let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {

        context.toViewController.view.transform = .identity
        if let fromViewController = context.fromViewController {
          fromViewController.view.transform = .init(translationX: -fromViewController.view.bounds.width, y: 0)
        }
        context.toViewController.view.alpha = 1

      }

      animator.addCompletion { _ in
        context.notifyAnimationCompleted()
      }

      animator.startAnimation()

    }

  }


}
