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
        context.notifyCompleted()
      }

      animator.startAnimation()

    }

  }

  public static func popupContextual(from coordinateSpace: UIView, snapshot: UIView) -> Self {

    return .init { context in

      let targetView = context.toViewController.view!

      let hasAnimations = (targetView.layer.animationKeys() ?? []).isEmpty == false

      if !hasAnimations {

        let frame = coordinateSpace.convert(coordinateSpace.bounds, to: context.contentView)

        let fromFrame = rectThatAspectFit(
          aspectRatio: context.contentView.bounds.size,
          boundingRect: frame
        )

        let target = makeTranslation(from: context.contentView.bounds, to: fromFrame)

        targetView.transform = .init(scaleX: target.scale.width, y: target.scale.height)
        targetView.center = target.center

        targetView.alpha = 1

        if #available(iOS 13.0, *) {
          targetView.layer.cornerCurve = .continuous
        } else {
          // Fallback on earlier versions
        }
        targetView.layer.cornerRadius = 80
        targetView.layer.masksToBounds = true

        /// snapshot
        do {
          context.contentView.addSubview(snapshot)
          snapshot.transform = .identity
          snapshot.frame = frame
          snapshot.alpha = 1
          snapshot.transform = .init(scaleX: 0.6, y: 0.6)
        }

      }

      context.toViewController.view.isUserInteractionEnabled = true

      let styleAnimator = UIViewPropertyAnimator(
        duration: 0.6,
        timingParameters: UISpringTimingParameters(
          dampingRatio: 1,
          initialVelocity: .zero
        )
      )

      styleAnimator.addAnimations {
        context.toViewController.view.alpha = 1
        context.toViewController.view.layer.cornerRadius = 0
        snapshot.alpha = 0
      }

      let snapshotAnimators = Fluid.makePropertyAnimatorsForTranformUsingCenter(
        view: snapshot,
        duration: 0.6,
        position: .custom(.init(x: 0, y: 0)),
        scale: .init(width: 0.5, height: 0.5),
        velocityForTranslation: .zero,
        velocityForScaling: 0
      )

      let translationAnimators = Fluid.makePropertyAnimatorsForTranformUsingCenter(
        view: context.toViewController.view,
        duration: 0.6,
        position: .center(of: context.toViewController.view.bounds),
        scale: .init(width: 1, height: 1),
        velocityForTranslation: .zero,
        velocityForScaling: 0
      )

      Fluid.startPropertyAnimators(
        translationAnimators + snapshotAnimators + [styleAnimator],
        completion: {
          context.notifyCompleted()
        })

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
        topViewController.view.transform = .init(scaleX: 0.8, y: 0.8)
        topViewController.view.center.y += 150

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
