import UIKit

/**
 A transition for removing in ``FluidStackController`` or ``TransitionViewController``
 */
public struct AnyBatchRemovingTransition {

  private let _startTransition: (BatchRemovingTransitionContext) -> Void

  public init(
    startTransition: @escaping (BatchRemovingTransitionContext) -> Void
  ) {
    self._startTransition = startTransition
  }

  public func startTransition(context: BatchRemovingTransitionContext) {
    _startTransition(context)
  }
}

extension AnyBatchRemovingTransition {

  public static func vanishing(duration: TimeInterval = 0.6) -> Self {

    return .init { context in

      let topViewController = context.fromViewControllers.last!
      let middleViewControllers = context.fromViewControllers.dropLast()

      middleViewControllers.forEach {
        $0.view.isHidden = true
      }

      let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {

        topViewController.view.alpha = 0

        context.toViewController?.view.transform = .identity
        context.toViewController?.view.alpha = 1

      }

      animator.addCompletion { _ in

        context.notifyCompleted()

        topViewController.view.alpha = 1
        middleViewControllers.forEach {
          $0.view.isHidden = false
        }

        context.fromViewControllers.forEach {
          $0.view.removeFromSuperview()
        }
      }

      animator.startAnimation()

    }

  }

}
