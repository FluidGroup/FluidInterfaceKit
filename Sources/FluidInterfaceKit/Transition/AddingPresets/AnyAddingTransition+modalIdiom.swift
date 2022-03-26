import UIKit

extension AnyAddingTransition {

  public static var modalStyle: Self {

    return .init { context in
      
      context.disableUserInteractionUntileFinish()

      context.contentView.backgroundColor = .clear

      if !Fluid.hasAnimations(view: context.toViewController.view) {

        context.toViewController.view.transform = .init(
          translationX: 0,
          y: context.toViewController.view.bounds.height
        )
      }

      let animator = UIViewPropertyAnimator(duration: 0.6, dampingRatio: 1) {

        context.toViewController.view.transform = .identity
        context.toViewController.view.alpha = 1
      }

      animator.addCompletion { _ in
        context.notifyAnimationCompleted()
      }

      animator.startAnimation()

    }

  }

}
