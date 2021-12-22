import UIKit

extension AnyAddingTransition {

  public static var noAnimation: Self {
    return .init { context in
    }
  }

  public static func popup(
    duration: TimeInterval = 0.6
  ) -> Self {

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

  public static func popupContextual(from coordinateSpace: UICoordinateSpace) -> Self {

    return .init { context in

      let frame = coordinateSpace.convert(coordinateSpace.bounds, to: context.contentView)

      let fromFrame = rectThatAspectFit(
        aspectRatio: context.contentView.bounds.size,
        boundingRect: frame
      )

      context.toViewController.view.layer.removeAllAnimations()

      let t = makeCGAffineTransform(from: context.contentView.bounds, to: fromFrame)

      context.toViewController.view.transform = t
      if #available(iOS 13.0, *) {
        context.toViewController.view.layer.cornerCurve = .continuous
      } else {
        // Fallback on earlier versions
      }
      context.toViewController.view.layer.cornerRadius = 80
      context.toViewController.view.layer.masksToBounds = true

      context.toViewController.view.alpha = 1

      let animator = UIViewPropertyAnimator(duration: 0.6, dampingRatio: 1) {

        context.toViewController.view.transform = .identity
        context.toViewController.view.alpha = 1
        context.toViewController.view.layer.cornerRadius = 0
      }

      animator.addCompletion { _ in
        Log.debug(.default, "animation completed")

        context.notifyCompleted()
      }

      animator.startAnimation()

    }

  }

}

extension AnyRemovingTransition {

  public static var noAnimation: Self {
    return .init { context in
      context.fromViewController.view.removeFromSuperview()
    }
  }

  public static func vanishing(duration: TimeInterval = 0.6) -> Self {

    return .init { context in

      let topViewController = context.fromViewController

      let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {

        topViewController.view.alpha = 0

        context.toViewController?.view.transform = .identity
        context.toViewController?.view.alpha = 1

      }

      animator.addCompletion { _ in
        topViewController.view.alpha = 1
        topViewController.view.removeFromSuperview()
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
