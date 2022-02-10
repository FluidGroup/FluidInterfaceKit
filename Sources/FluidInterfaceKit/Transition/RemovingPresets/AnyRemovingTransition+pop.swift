import UIKit

extension AnyRemovingTransition {

  public static func navigationIdiom(
    duration: TimeInterval = 0.6
  ) -> Self {

    return .init { context in

      context.fromViewController.view.transform = .identity

      if let fromViewController = context.toViewController {
        fromViewController.view.transform = .init(translationX: -fromViewController.view.bounds.width, y: 0)
      }

      let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {

        context.fromViewController.view.transform = .init(translationX: context.fromViewController.view.bounds.width, y: 0)

        if let fromViewController = context.toViewController {
          fromViewController.view.transform = .identity
        }

      }

      animator.addCompletion { _ in

        if let fromViewController = context.toViewController {
          fromViewController.view.transform = .identity
        }

        context.notifyAnimationCompleted()
      }

      animator.startAnimation()

    }

  }

}