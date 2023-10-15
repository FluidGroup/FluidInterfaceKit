
import UIKit

extension AnyRemovingTransition {

  public static var vanishing: Self {

    return .init { context in

      let topViewController = context.fromViewController

      let animator = UIViewPropertyAnimator(duration: 0.6, dampingRatio: 1) {

        topViewController.view.alpha = 0
        topViewController.view.layer.transform = CATransform3DMakeAffineTransform(
          .init(scaleX: 0.8, y: 0.8).translatedBy(x: 0, y: 60)
        )

        context.contentView.backgroundColor = .clear
        context.toViewController?.view.alpha = 1

      }

      animator.addCompletion { _ in
        context.notifyAnimationCompleted()
      }

      animator.startAnimation()

    }

  }

}
