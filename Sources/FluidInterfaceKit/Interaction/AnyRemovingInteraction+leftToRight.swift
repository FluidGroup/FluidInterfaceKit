import UIKit

extension AnyRemovingInteraction {

  // FIXME: not completed
  public static var leftToRight: Self {

    struct TrackingContext {

      let transitionContext: RemovingTransitionContext
      let viewFrame: CGRect
      let beganPoint: CGPoint
      let animator: UIViewPropertyAnimator

      func normalizedVelocity(gesture: UIPanGestureRecognizer) -> CGFloat {
        let velocityX = gesture.velocity(in: gesture.view).x
        return velocityX / viewFrame.width
      }

      func calulateProgress(gesture: UIPanGestureRecognizer) -> CGFloat {
        let targetView = gesture.view!
        let t = targetView.transform
        targetView.transform = .identity
        let position = gesture.location(in: targetView)
        targetView.transform = t

        let progress = (position.x - beganPoint.x) / viewFrame.width
        return progress
      }
    }

    var trackingContext: TrackingContext?

    return .init(
      handlers: [
        .gestureOnLeftEdge(
          handler: { gesture, context in

            let view = context.viewController.view!

            let backViewController: UIViewController? = {
              guard
                let controllers = context.viewController.fluidStackContext?.fluidStackController?.stackingViewControllers,
                let index = controllers.firstIndex(of: context.viewController)
              else {
                return nil
              }
              let target = index.advanced(by: -1)
              if controllers.indices.contains(target) {
                return controllers[target]
              } else {
                return nil
              }
            }()

            switch gesture.state {
            case .possible:
              break
            case .began:

              break

            case .changed:

              if trackingContext == nil {

                if abs(gesture.translation(in: view).y) > 5 {
                  gesture.state = .failed
                  return
                }

                if gesture.translation(in: view).x < -5 {
                  gesture.state = .failed
                  return
                }

                guard gesture.translation(in: view).x > 0 else {
                  return
                }

                /**
                 Prepare to interact
                 */

                let currentTransform =
                  view.layer.presentation().map {
                    CATransform3DGetAffineTransform($0.transform)
                  } ?? .identity

                view.transform = currentTransform
                backViewController?.view.transform = currentTransform.translatedBy(x: -view.bounds.width, y: 0)

                let transitionContext = context.startRemovingTransition()

                let animator = UIViewPropertyAnimator(duration: 0.62, dampingRatio: 1) {
                  view.transform = currentTransform.translatedBy(x: view.bounds.width, y: 0)
                  backViewController?.view.transform = .identity
                }

                animator.addCompletion { position in
                  switch position {
                  case .end:
                    transitionContext.notifyAnimationCompleted()
                  case .start:
                    break
                  case .current:
                    assertionFailure("")
                    break
                  @unknown default:
                    assertionFailure("")
                  }
                }

                let newTrackingContext = TrackingContext(
                  transitionContext: transitionContext,
                  viewFrame: view.bounds,
                  beganPoint: gesture.location(in: view),
                  animator: animator
                )

                trackingContext = newTrackingContext

              }

              if let context = trackingContext {
                let progress = context.calulateProgress(gesture: gesture)
                context.animator.fractionComplete = progress
              }

            case .ended:

              guard let _trackingContext = trackingContext else {
                return
              }

              backViewController?.view.transform = .identity

              let progress = _trackingContext.calulateProgress(gesture: gesture)
              let velocity = gesture.velocity(in: gesture.view)

              if progress > 0.5 || velocity.x > 300 {

                let velocityX = _trackingContext.normalizedVelocity(gesture: gesture)
                _trackingContext.animator.continueAnimation(
                  withTimingParameters: UISpringTimingParameters(
                    dampingRatio: 1,
                    initialVelocity: .init(dx: velocityX, dy: 0)
                  ),
                  durationFactor: 1
                )

              } else {

                _trackingContext.animator.stopAnimation(true)
                let animator = UIViewPropertyAnimator(duration: 0.62, dampingRatio: 1) {
                  view.transform = .identity
                  backViewController?.view.transform = view.transform.translatedBy(x: -view.bounds.width, y: 0)
                }
                animator.addCompletion { position in
                  backViewController?.view.transform = .identity
                  _trackingContext.transitionContext.notifyCancelled()
                }
                animator.startAnimation()

              }

              trackingContext = nil

            case .cancelled, .failed:

              guard let _trackingContext = trackingContext else {
                return
              }

              backViewController?.view.transform = .identity

              _trackingContext.transitionContext.notifyCancelled()

              trackingContext = nil

            /// restore view state
            @unknown default:
              break
            }

          }
        )
      ]
    )
  }

}
