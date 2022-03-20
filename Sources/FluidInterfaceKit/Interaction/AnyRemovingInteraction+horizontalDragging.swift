import GeometryKit
import ResultBuilderKit
import UIKit

extension AnyRemovingInteraction {

  public enum HorizontalDraggingBackwardingMode {
    // TODO: get a generic name
    case instagramThreads(
      destinationView: UIView,
      destinationMirroViewProvider: AnyMirrorViewProvider
    )
    case shape(
      destinationComponent: ContextualTransitionSourceComponentType
    )
  }

  /**
   Instagram Threads like transition
   */
  public static func horizontalDragging(
    backwardingMode: HorizontalDraggingBackwardingMode?
  ) -> Self {

    struct TrackingContext {

      var scrollController: ScrollController?
      let transitionContext: RemovingTransitionContext

    }

    /// a shared state
    var trackingContext: TrackingContext?

    return .init(
      handlers: [
        .gestureOnLeftEdge { gesture, context in
        
          switch gesture.state {
          case .began:

            switch backwardingMode {
            case .instagramThreads(
              let destinationView,
              let destinationMirroViewProvider
            ):
              // TODO: Impl
              break
            case .shape(
              let destinationComponent
            ):
              let transitionContext = context.startRemovingTransition()

              let sourceView = transitionContext.fromViewController.view!

              AnyRemovingInteraction.Contextual.runEnclosing(
                transitionContext: transitionContext,
                disclosedView: sourceView,
                destinationComponent: destinationComponent,
                gestureVelocity: .zero
              )
            case .none:
              // TODO: handle
              break
            }

          default:
            break
          }
        },

        .gestureOnScreen(
          handler: { gesture, context in

            let draggingView = context.viewController.view!
            assert(draggingView == gesture.view)

            switch gesture.state {
            case .possible:
              break

            case .began, .changed:

              if trackingContext == nil {

                guard abs(gesture.translation(in: draggingView).y) <= 10 else {
                  gesture.state = .failed
                  return
                }

                /**
                 Prepare to interact
                 */

                let transitionContext = context.startRemovingTransition()

                var newTrackingContext = TrackingContext(
                  scrollController: nil,
                  transitionContext: transitionContext
                )

                transitionContext.addCompletionEventHandler { event in
                  gesture.view!.layer.cornerRadius = 0
                }

                if let scrollView = gesture.trackingScrollView {

                  let representation = ScrollViewRepresentation(from: scrollView)

                  if representation.isReachedToEdge(.left) {

                    let newScrollController = ScrollController(scrollView: scrollView)
                    newScrollController.lockScrolling()

                    newTrackingContext.scrollController = newScrollController

                  } else {
                    gesture.state = .failed
                    return
                  }

                }

                trackingContext = newTrackingContext

              }

              guard trackingContext != nil else {
                return
              }

              let translation =
                gesture
                .translation(in: draggingView)
                .applying(draggingView.transform)

              draggingView.layer.position.x += translation.x
              draggingView.layer.position.y += translation.y
              draggingView.layer.masksToBounds = true
              if #available(iOS 13.0, *) {
                draggingView.layer.cornerCurve = .continuous
              } else {
                // Fallback on earlier versions
              }

              UIViewPropertyAnimator(duration: 0.5, dampingRatio: 1) {
                draggingView.layer.cornerRadius = 24
              }
              .startAnimation()

              gesture.setTranslation(.zero, in: draggingView)

            case .ended:

              guard let _trackingContext = trackingContext else {
                return
              }

              let transitionContext = _trackingContext.transitionContext

              _trackingContext.scrollController?.unlockScrolling()
              _trackingContext.scrollController?.endTracking()

              let velocity = gesture.velocity(in: gesture.view)

              let originalCenter = CGPoint(x: draggingView.bounds.midX, y: draggingView.bounds.midY)
              let distanceFromCenter = CGPoint(
                x: originalCenter.x - draggingView.center.x,
                y: originalCenter.y - draggingView.center.y
              )

              let startsBackwarding =
                abs(distanceFromCenter.x) > 80 || abs(distanceFromCenter.y) > 80
                || abs(velocity.x) > 100 || abs(velocity.y) > 100

              defer {
                trackingContext = nil
              }

              if startsBackwarding {

                guard let backwardingMode = backwardingMode else {
                  /// fallback

                  let animator = UIViewPropertyAnimator(
                    duration: 0.62,
                    timingParameters: UISpringTimingParameters(
                      dampingRatio: 1,
                      initialVelocity: .zero
                    )
                  )

                  animator.addAnimations {
                    draggingView.layer.transform = CATransform3DMakeAffineTransform(
                      .init(scaleX: 0.8, y: 0.8)
                    )
                    draggingView.alpha = 0
                    _trackingContext.transitionContext.contentView.backgroundColor = .clear
                  }

                  animator.addCompletion { _ in
                    _trackingContext.transitionContext.notifyAnimationCompleted()
                  }

                  animator.startAnimation()

                  return
                }

                switch backwardingMode {
                case .instagramThreads(let destinationView, let destinationMirroViewProvider):

                  AnyRemovingInteraction.Contextual.runZoomOut(
                    transitionContext: transitionContext,
                    disclosedView: draggingView,
                    destinationView: destinationView,
                    destinationMirroViewProvider: destinationMirroViewProvider,
                    gestureVelocity: gesture.velocity(in: gesture.view)
                  )
                 
                case .shape(
                  let destinationComponent
                ):

                  AnyRemovingInteraction.Contextual.runEnclosing(
                    transitionContext: transitionContext,
                    disclosedView: draggingView,
                    destinationComponent: destinationComponent,
                    gestureVelocity: gesture.velocity(in: gesture.view)
                  )

                }

              } else {

                transitionContext.notifyCancelled()
                /// animation for cancel

                let animator = UIViewPropertyAnimator(
                  duration: 0.62,
                  timingParameters: UISpringTimingParameters(
                    dampingRatio: 1,
                    initialVelocity: .zero
                  )
                )

                animator.addAnimations {
                  draggingView.center = .init(
                    x: draggingView.bounds.width / 2,
                    y: draggingView.bounds.height / 2
                  )
                  draggingView.transform = .identity
                  draggingView.layer.cornerRadius = 0
                }

                animator.startAnimation()
              }

            case .cancelled, .failed:
                            
              guard let _trackingContext = trackingContext else {
                return
              }
              
              _trackingContext.transitionContext.notifyCancelled()

              _trackingContext.scrollController?.unlockScrolling()
              _trackingContext.scrollController?.endTracking()

              draggingView.center = CGPoint(
                x: draggingView.bounds.width / 2,
                y: draggingView.bounds.height / 2
              )
              draggingView.transform = .identity
              draggingView.layer.cornerRadius = 0

              trackingContext = nil

            /// restore view state
            @unknown default:
              break
            }
          }
        ),
      ]
    )
  }
}
