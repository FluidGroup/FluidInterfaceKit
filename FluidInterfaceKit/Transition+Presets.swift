import UIKit
import GeometryKit
import ResultBuilderKit

extension AnyAddingTransition {

  public static var noAnimation: Self {
    return .init { context in
      context.notifyCompleted()
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

  public static func instagramThreads(
    from entrypointView: UIView,
    interpolationView: UIView,
    hidingViews: [UIView]
  ) -> Self {

    return .init { (context: AddingTransitionContext) in

      // FIXME: tmp impl
      BatchApplier(hidingViews).setInvisible(true)
      
      context.addEventHandler { event in
        BatchApplier(hidingViews).setInvisible(false)
      }

      let targetView = context.toViewController.view!

      if !Fluid.hasAnimations(view: targetView) {

        let frame = entrypointView.convert(entrypointView.bounds, to: context.contentView)

        let target = makeTranslation(
          from: context.contentView.bounds,
          to: Geometry.rectThatAspectFit(
            aspectRatio: context.contentView.bounds.size,
            boundingRect: frame
          )
        )

        targetView.transform = .init(scaleX: target.scale.width, y: target.scale.height)
        targetView.center = target.center

        targetView.alpha = 1

        if #available(iOS 13.0, *) {
          targetView.layer.cornerCurve = .continuous
        } else {
          // Fallback on earlier versions
        }
        targetView.layer.cornerRadius = 8
        targetView.layer.masksToBounds = true

        /// snapshot
        do {
          context.contentView.addSubview(interpolationView)
          interpolationView.transform = .identity
          interpolationView.frame = frame
          interpolationView.alpha = 1
          interpolationView.transform = .init(scaleX: 0.6, y: 0.6)
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
        context.contentView.backgroundColor = .init(white: 0, alpha: 0.6)
        interpolationView.alpha = 0
      }

      let snapshotAnimators = Fluid.makePropertyAnimatorsForTranformUsingCenter(
        view: interpolationView,
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
        buildArray {
          translationAnimators
          snapshotAnimators
          styleAnimator
        },
        completion: {
          context.notifyCompleted()
        }
      )

    }

  }

  public static func expanding(from entrypointView: UIView, hidingViews: [UIView]) -> Self {

    return .init { (context: AddingTransitionContext) in

      // FIXME: tmp impl
      BatchApplier(hidingViews).setInvisible(true)

      context.addEventHandler { event in
        BatchApplier(hidingViews).setInvisible(false)
      }

      let maskView = UIView()
      maskView.backgroundColor = .black

      let entrypointSnapshotView = Fluid.takeSnapshotVisible(view: entrypointView)

      if !Fluid.hasAnimations(view: context.toViewController.view) {

        maskView.frame = context.toViewController.view.bounds

        if #available(iOS 13.0, *) {
          maskView.layer.cornerCurve = .continuous
        } else {
          // Fallback on earlier versions
        }
        maskView.layer.cornerRadius = 24

        context.toViewController.view.mask = maskView

        context.addEventHandler { _ in
          entrypointSnapshotView.removeFromSuperview()
        }

        context.contentView.addSubview(entrypointSnapshotView)
        entrypointSnapshotView.frame = context.frameInContentView(for: entrypointView)

        let fromFrame = CGRect(
          origin: context.frameInContentView(for: entrypointView).origin,
          size: Geometry.sizeThatAspectFill(
            aspectRatio: context.toViewController.view.bounds.size,
            minimumSize: entrypointView.bounds.size
          )
        )

        /// make initial state for displaying view
        let translation = makeTranslation(
          from: context.contentView.bounds,
          to: fromFrame
        )

        context.toViewController.view.transform = .init(scaleX: translation.scale.width, y: translation.scale.height)
        context.toViewController.view.center = translation.center
        context.toViewController.view.alpha = 0.2

        // fix visually height against transforming
        maskView.frame.size.height = entrypointView.bounds.height / translation.scale.height

      }

      let translationAnimators = Fluid.makePropertyAnimatorsForTranformUsingCenter(
        view: context.toViewController.view,
        duration: 0.7,
        position: .center(of: context.toViewController.view.bounds),
        scale: .init(width: 1, height: 1),
        velocityForTranslation: .zero,
        velocityForScaling: 0
      )

      let translationForSnapshot = makeTranslation(
        from: entrypointSnapshotView.frame,
        to: .init(origin: .zero, size: entrypointSnapshotView.frame.size)
      )

      let snapshotTranslationAnimators = Fluid.makePropertyAnimatorsForTranformUsingCenter(
        view: entrypointSnapshotView,
        duration: 0.7,
        position: .custom(translationForSnapshot.center),
        scale: translationForSnapshot.scale,
        velocityForTranslation: .zero,
        velocityForScaling: 0
      )

      let maskAnimator = UIViewPropertyAnimator(duration: 0.6, dampingRatio: 1) {
        maskView.transform = .identity
        maskView.frame = context.toViewController.view.bounds
      }

      maskAnimator.addAnimations({
        maskView.layer.cornerRadius = 0
      }, delayFactor: 0.1)

      maskAnimator.addCompletion { _ in
        context.toViewController.view.mask = nil
      }

      let crossfadeAnimator = UIViewPropertyAnimator(duration: 0.3, dampingRatio: 1) {
        context.toViewController.view.alpha = 1
        entrypointSnapshotView.alpha = 0
        context.contentView.backgroundColor = .init(white: 0, alpha: 0.6)
      }

      Fluid.startPropertyAnimators(
        buildArray {
          translationAnimators
          maskAnimator
          snapshotTranslationAnimators
          crossfadeAnimator
        },
        completion: {
          context.notifyCompleted()
        }
      )

    }
  }
}

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
