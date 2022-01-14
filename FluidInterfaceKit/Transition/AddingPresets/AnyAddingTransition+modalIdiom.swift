import UIKit

extension AnyAddingTransition {

  public static func modalIdiom(
    duration: TimeInterval = 0.4
    ) -> Self {

      return .init { context in

        context.toViewController.view.transform = .init(translationX: 0, y: context.toViewController.view.bounds.height)

        let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {

          context.toViewController.view.transform = .identity
          context.toViewController.view.alpha = 1
        }

        animator.addCompletion { _ in
          context.notifyCompleted()
        }

        animator.startAnimation()

      }

    }

}
