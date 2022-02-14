import UIKit

extension AnyRemovingTransition {

  public static var modalStyle: Self {

    return .init { context in

      context.contentView.backgroundColor = .clear

      let animator = UIViewPropertyAnimator(duration: 0.6, dampingRatio: 1) {

        context.fromViewController.view.layer.transform = CATransform3DMakeAffineTransform(.init(
          translationX: 0,
          y: context.fromViewController.view.bounds.height
        ))
        context.fromViewController.view.alpha = 1
        
      }

      animator.addCompletion { _ in
        context.notifyAnimationCompleted()
      }

      animator.startAnimation()

    }

  }

}
