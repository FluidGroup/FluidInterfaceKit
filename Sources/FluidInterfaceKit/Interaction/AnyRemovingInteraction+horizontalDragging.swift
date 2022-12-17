import GeometryKit
import ResultBuilderKit
import UIKit

extension AnyRemovingInteraction {

  public enum Dragging {

    public struct AnyBackwarding {

      public enum Event {
        case dragging
        case cancelled
        case run(
          transitionContext: RemovingTransitionContext,
          draggingView: UIView,
          gestureVelocity: CGPoint
        )
      }

      private let _eventHandler: (Event) -> Void

      public init(eventHandler: @escaping (Event) -> Void) {
        self._eventHandler = eventHandler
      }

      func receive(event: Event) {
        _eventHandler(event)
      }

      /// For fallback transition
      public static var vanishing: Self {
        return .init { event in
          switch event {
          case .dragging:
            break
          case .cancelled:
            break
          case let .run(transitionContext, draggingView, _):
          
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
              transitionContext.contentView.backgroundColor = .clear
            }

            animator.addCompletion { _ in
              transitionContext.notifyAnimationCompleted()
            }

            animator.startAnimation()

          }
        }
      }

      public static func enclosing(to component: ContextualTransitionSourceComponentType) -> Self {
        return .init { event in
          switch event {
          case .dragging:

            component.contentView.isHidden = true

          case .cancelled:

            component.contentView.isHidden = false

          case .run(
            let transitionContext,
            let draggingView,
            let gestureVelocity
          ):

            component.contentView.isHidden = false

            AnyRemovingInteraction.Contextual.runEnclosing(
              transitionContext: transitionContext,
              disclosedView: draggingView,
              destinationComponent: component,
              gestureVelocity: gestureVelocity
            )

          }
        }
      }

      public static func gettingTogether(to component: ContextualTransitionSourceComponentType)
        -> Self
      {
        return .init { event in
          switch event {
          case .dragging:

            component.contentView.isHidden = true

          case .cancelled:

            component.contentView.isHidden = false

          case .run(
            let transitionContext,
            let draggingView,
            let gestureVelocity
          ):

            component.contentView.isHidden = false

            AnyRemovingInteraction.Contextual.runGettingTogether(
              transitionContext: transitionContext,
              disclosedView: draggingView,
              destinationComponent: component,
              gestureVelocity: gestureVelocity
            )

          }
        }
      }

    }

  }

  /**
   Instagram Threads like transition
   */
  public static func horizontalDragging(
    isEdgeEnabled: Bool = false,
    backwarding makeBackwarding: @escaping () -> Dragging.AnyBackwarding
  ) -> Self {

    struct TrackingContext {

      var scrollController: ScrollController?
      let backwardingMode: Dragging.AnyBackwarding
      let transitionContext: RemovingTransitionContext

    }

    /// a shared state
    var trackingContext: TrackingContext?

    return .init(
      handlers: buildArray {
        if isEdgeEnabled {
          .gestureOnLeftEdge(
            condition: { gesture, event  in
              switch event {
              case .shouldBeRequiredToFailBy(let otherGestureRecognizer, let completion):
                
                if otherGestureRecognizer is UIPanGestureRecognizer {
                  completion(true)
                } else {
                  completion(false)
                }
                
              case .shouldRecognizeSimultaneouslyWith(let otherGestureRecognizer, let completion):
                
                if otherGestureRecognizer is UIPanGestureRecognizer {
                  // to make ScrollView prior.
                  completion(false)
                } else {
                  completion(true)
                }
                
              }
            },
            handler: { gesture, context in
              
              switch gesture.state {
              case .began:
                
                let backwarding = makeBackwarding()
                let transitionContext = context.startRemovingTransition()
                
                backwarding.receive(
                  event: .run(
                    transitionContext: transitionContext,
                    draggingView: transitionContext.fromViewController.view!,
                    gestureVelocity: .zero
                  )
                )
                
              default:
                break
              }
            }
          )
        }

        .gestureOnScreen(
          condition: { gesture, event in
            switch event {
            case .shouldBeRequiredToFailBy(_, let completion):
              
              completion(false)
              
            case .shouldRecognizeSimultaneouslyWith(let otherGestureRecognizer, let completion):
              
              if otherGestureRecognizer is UIPanGestureRecognizer {
                // to make ScrollView prior.
                completion(false)
              } else {
                completion(true)
              }
              
            }
          },
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

                let backwarding = makeBackwarding()
                backwarding.receive(event: .dragging)

                let transitionContext = context.startRemovingTransition()

                var newTrackingContext = TrackingContext(
                  scrollController: nil,
                  backwardingMode: backwarding,
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
                    transitionContext.notifyCancelled()
                    return
                  }

                }

                trackingContext = newTrackingContext

              }

              guard trackingContext != nil else {
                return
              }

              draggingView.layer.masksToBounds = true
              if #available(iOS 13.0, *) {
                draggingView.layer.cornerCurve = .continuous
              } else {
                // Fallback on earlier versions
              }

              let translation = gesture.translation(in: draggingView)
              
              let movingAnimator = UIViewPropertyAnimator(duration: 0.35, dampingRatio: 1)
              
              movingAnimator.addAnimations {
                // The reason why it uses `layer` is prevent layout in safe-area.
                draggingView.layer.position.x += translation.x
                draggingView.layer.position.y += translation.y
                draggingView.layer.cornerRadius = 32
                trackingContext?.transitionContext.contentView.backgroundColor = .init(white: 0, alpha: 0.2)
              }
              
              movingAnimator.startAnimation()

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

                _trackingContext.backwardingMode.receive(
                  event: .run(
                    transitionContext: _trackingContext.transitionContext,
                    draggingView: draggingView,
                    gestureVelocity: gesture.velocity(in: gesture.view)
                  )
                )

              } else {
               
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

                animator.addCompletion { position in
                  if case .end = position {
                    transitionContext.notifyCancelled()
                  }
                }
                
                animator.startAnimation()

                _trackingContext.backwardingMode.receive(
                  event: .cancelled
                )
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
        )
      }
    )
  }
}
