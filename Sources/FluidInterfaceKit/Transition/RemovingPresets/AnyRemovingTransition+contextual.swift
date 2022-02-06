import GeometryKit
import ResultBuilderKit
import UIKit

extension AnyRemovingTransition {

  public static func contextual(
    destinationView: UIView,
    destinationMirroViewProvider: AnyMirrorViewProvider
  ) -> Self {

    return .init { context in
      
      let sourceView = context.fromViewController.view!
      
      AnyRemovingInteraction.Contextual.run(
        transitionContext: context,
        sourceView: sourceView,
        destinationView: destinationView,
        destinationMirroViewProvider: destinationMirroViewProvider,
        gestureVelocity: .zero
      )
      
    }

  }

}

extension AnyRemovingInteraction {
  public enum Contextual {
        
    public static func run(
      transitionContext: RemovingTransitionContext,
      sourceView: UIView,
      destinationView: UIView,
      destinationMirroViewProvider: AnyMirrorViewProvider,
      gestureVelocity: CGPoint?
    ) {
      
      let draggingView = sourceView

      let maskView = UIView()
      maskView.backgroundColor = .black

      maskView.frame = transitionContext.fromViewController.view.bounds
      transitionContext.fromViewController.view.mask = maskView
                        
      let entrypointSnapshotView = destinationMirroViewProvider.view()

      transitionContext.contentView.addSubview(entrypointSnapshotView)
      entrypointSnapshotView.frame = .init(origin: draggingView.frame.origin, size: destinationView.bounds.size)
      entrypointSnapshotView.alpha = 0

      transitionContext.addCompletionEventHandler { _ in
        entrypointSnapshotView.removeFromSuperview()
      }

      let translation = Geometry.centerAndScale(
        from: transitionContext.fromViewController.view.frame,
        to: CGRect(
          origin: transitionContext.frameInContentView(for: destinationView).origin,
          size: Geometry.sizeThatAspectFill(
            aspectRatio: transitionContext.fromViewController.view.bounds.size,
            minimumSize: destinationView.bounds.size
          )
        )
      )

      let velocityForAnimation: CGVector = {
        
        guard let gestureVelocity = gestureVelocity else {
          return .zero
        }

        let targetCenter = translation.center
        let delta = CGPoint(
          x: targetCenter.x - draggingView.center.x,
          y: targetCenter.y - draggingView.center.y
        )

        let velocity = CGVector.init(
          dx: gestureVelocity.x / delta.x,
          dy: gestureVelocity.y / delta.y
        )

        return velocity

      }()

      Fluid.startPropertyAnimators(
        buildArray {
          Fluid.makePropertyAnimatorsForTranformUsingCenter(
            view: transitionContext.fromViewController.view,
            duration: 0.8,
            position: .custom(translation.center),
            scale: translation.scale,
            velocityForTranslation: velocityForAnimation,
            velocityForScaling: 2
          )
          UIViewPropertyAnimator(duration: 0.6, dampingRatio: 1) {
            transitionContext.contentView.backgroundColor = .clear
          }
          UIViewPropertyAnimator(duration: 0.8, dampingRatio: 0.8) {
            entrypointSnapshotView.frame = transitionContext.frameInContentView(for: destinationView)
            entrypointSnapshotView.alpha = 1
          }
          UIViewPropertyAnimator(duration: 0.6, dampingRatio: 1) {
            transitionContext.fromViewController.view.alpha = 0
          }
          UIViewPropertyAnimator(duration: 0.6, dampingRatio: 1) {
            maskView.frame = transitionContext.fromViewController.view.bounds
            maskView.frame.size.height = destinationView.bounds.height / translation.scale.y
            maskView.layer.cornerRadius = 24
            if #available(iOS 13.0, *) {
              maskView.layer.cornerCurve = .continuous
            } else {
              // Fallback on earlier versions
            }
          }
        },
        completion: {
          transitionContext.notifyAnimationCompleted()
        }
      )
    }
  }
}
