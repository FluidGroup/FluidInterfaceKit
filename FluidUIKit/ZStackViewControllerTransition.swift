
import UIKit

public final class ZStackViewControllerAddingTransitionContext: Equatable {

  public static func == (lhs: ZStackViewControllerAddingTransitionContext, rhs: ZStackViewControllerAddingTransitionContext) -> Bool {
    lhs === rhs
  }

  public let contentView: UIView
  public let fromViewController: UIViewController?
  public let toViewController: UIViewController

  init(
    contentView: UIView,
    fromViewController: UIViewController?,
    toViewController: UIViewController
  ) {
    self.contentView = contentView
    self.fromViewController = fromViewController
    self.toViewController = toViewController
  }

}

public final class ZStackViewControllerRemovingTransitionContext: Equatable {

  public static func == (lhs: ZStackViewControllerRemovingTransitionContext, rhs: ZStackViewControllerRemovingTransitionContext) -> Bool {
    lhs === rhs
  }

  public let contentView: UIView
  public let fromViewControllers: [UIViewController]
  public let toViewController: UIViewController?

  init(
    contentView: UIView,
    fromViewControllers: [UIViewController],
    toViewController: UIViewController?
  ) {
    self.contentView = contentView
    self.fromViewControllers = fromViewControllers
    self.toViewController = toViewController
  }
}

public struct AnyZStackViewControllerAddingTransition {

  private let _startTransition: (ZStackViewControllerAddingTransitionContext) -> Void

  public init(
    startTransition: @escaping (ZStackViewControllerAddingTransitionContext) -> Void
  ) {
    self._startTransition = startTransition
  }

  public func startTransition(context: ZStackViewControllerAddingTransitionContext) {
    _startTransition(context)
  }
}

extension AnyZStackViewControllerAddingTransition {

  public static func popup(duration: TimeInterval = 0.6) -> Self {

    return .init { context in

      context.toViewController.view.transform = .init(scaleX: 0.8, y: 0.8)
      context.toViewController.view.alpha = 0

      let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {

        context.toViewController.view.transform = .identity
        context.toViewController.view.alpha = 1

      }

      animator.addCompletion { _ in
      }

      animator.startAnimation()

    }

  }

}

public struct AnyZStackViewControllerRemovingTransition {

  private let _startTransition: (ZStackViewControllerRemovingTransitionContext) -> Void

  public init(
    startTransition: @escaping (ZStackViewControllerRemovingTransitionContext) -> Void
  ) {
    self._startTransition = startTransition
  }

  public func startTransition(context: ZStackViewControllerRemovingTransitionContext) {
    _startTransition(context)
  }
}

extension AnyZStackViewControllerRemovingTransition {

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
