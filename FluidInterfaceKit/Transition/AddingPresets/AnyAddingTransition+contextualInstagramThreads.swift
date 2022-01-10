import UIKit
import GeometryKit
import ResultBuilderKit

extension AnyAddingTransition {

  public static func contextualInstagramThreads(
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

        let target = Geometry.centerAndScale(
          from: context.contentView.bounds,
          to: Geometry.rectThatAspectFit(
            aspectRatio: context.contentView.bounds.size,
            boundingRect: frame
          )
        )

        targetView.transform = .init(scaleX: target.scale.x, y: target.scale.y)
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
        scale: .init(x: 0.5, y: 0.5),
        velocityForTranslation: .zero,
        velocityForScaling: 0
      )

      let translationAnimators = Fluid.makePropertyAnimatorsForTranformUsingCenter(
        view: context.toViewController.view,
        duration: 0.6,
        position: .center(of: context.toViewController.view.bounds),
        scale: .init(x: 1, y: 1),
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

}
