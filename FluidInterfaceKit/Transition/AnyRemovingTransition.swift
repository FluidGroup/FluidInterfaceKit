import UIKit
import GeometryKit
import ResultBuilderKit

/**
 A transition for removing in ``FluidStackViewController`` or ``TransitionViewController``
 */
public struct AnyRemovingTransition {

  private let _startTransition: (RemovingTransitionContext) -> Void

  public init(
    startTransition: @escaping (RemovingTransitionContext) -> Void
  ) {
    self._startTransition = startTransition
  }

  public func startTransition(context: RemovingTransitionContext) {
    _startTransition(context)
  }
}

// MARK: - Presets
extension AnyRemovingTransition {

  public static var noAnimation: Self {
    return .init { context in
      context.notifyCompleted()
    }
  }

  public static func vanishing(duration: TimeInterval = 0.6) -> Self {

    return .init { context in

      let topViewController = context.fromViewController

      let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {

        topViewController.view.alpha = 0
        topViewController.view.transform = .init(scaleX: 0.8, y: 0.8)
        topViewController.view.center.y += 150

        context.contentView.backgroundColor = .clear
        context.toViewController?.view.alpha = 1

      }

      animator.addCompletion { _ in
        context.notifyCompleted()
      }

      animator.startAnimation()

    }

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
