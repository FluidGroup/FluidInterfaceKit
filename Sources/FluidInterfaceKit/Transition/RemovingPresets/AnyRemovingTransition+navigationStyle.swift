import UIKit

extension AnyRemovingTransition {

  /**
   Similar to transition of UINavigationController.
   It runs animations with blocking user interactions.
   
   Opposite transition: ``AnyAddingTransition/navigationStyle``
   */
  public static var navigationStyle: Self {

    return .init { context in
      
      context.disableUserInteractionUntileFinish()

      context.fromViewController.view.transform = .identity

      if let fromViewController = context.toViewController {
        fromViewController.view.transform = .init(translationX: -fromViewController.view.bounds.width, y: 0)
      }

      let animator = UIViewPropertyAnimator(duration: 0.6, dampingRatio: 1) {

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
