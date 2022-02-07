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
      destinationComponent: ContextualTransitionSourceComponentType,
      destinationMirroViewProvider: AnyMirrorViewProvider
    )
  }

  /**
   Instagram Threads like transition
   */
  public static func horizontalDragging(
    backwardingMode: HorizontalDraggingBackwardingMode?,
    hidingViews: [UIView]
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
              let destinationComponent,
              let destinationMirroViewProvider
            ):
              let transitionContext = context.startRemovingTransition()

              let sourceView = transitionContext.fromViewController.view!

              AnyRemovingInteraction.Contextual.run(
                transitionContext: transitionContext,
                disclosedView: sourceView,
                destinationComponent: destinationComponent,
                destinationMirroViewProvider: destinationMirroViewProvider,
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

                BatchApplier(hidingViews).setInvisible(true)

                transitionContext.addCompletionEventHandler { event in
                  BatchApplier(hidingViews).setInvisible(false)
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

                  let interpolationView = destinationMirroViewProvider.view()

                  var targetRect = Geometry.rectThatAspectFit(
                    aspectRatio: draggingView.bounds.size,
                    boundingRect: transitionContext.frameInContentView(for: destinationView)
                  )

                  targetRect = targetRect.insetBy(
                    dx: targetRect.width / 3,
                    dy: targetRect.height / 3
                  )

                  let translation = Geometry.centerAndScale(
                    from: draggingView.bounds,
                    to: targetRect
                  )

                  let velocityForAnimation: CGVector = {

                    let targetCenter = translation.center
                    let gestureVelocity = gesture.velocity(in: gesture.view!)
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

                  let velocityForScaling: CGFloat = {

                    //                    let gestureVelocity = gesture.velocity(in: gesture.view!)

                    // TODO: calculate dynamic velocity
                    // set greater than 0, throwing animation would be more clear. like springboard
                    return 0

                  }()

                  var animators: [UIViewPropertyAnimator] = []

                  let translationAnimators = Fluid.makePropertyAnimatorsForTranformUsingCenter(
                    view: draggingView,
                    duration: 0.85,
                    position: .custom(translation.center),
                    scale: translation.scale,
                    velocityForTranslation: velocityForAnimation,
                    velocityForScaling: velocityForScaling  //sqrt(pow(velocityForAnimation.dx, 2) + pow(velocityForAnimation.dy, 2))
                  )

                  let backgroundAnimator = UIViewPropertyAnimator(duration: 0.6, dampingRatio: 1) {
                    _trackingContext.transitionContext.contentView.backgroundColor = .clear
                  }

                  animators += translationAnimators + [backgroundAnimator]

                  /// handling interpolation view
                  do {
                    interpolationView.center = .init(
                      x: draggingView.frame.minX,
                      y: draggingView.frame.minY
                    )
                    interpolationView.transform = .init(scaleX: 0.5, y: 0.5)

                    _trackingContext.transitionContext.contentView.addSubview(interpolationView)

                    let interpolationViewAnimators =
                      Fluid.makePropertyAnimatorsForTranformUsingCenter(
                        view: interpolationView,
                        duration: 0.85,
                        position: .custom(translation.center),
                        scale: .init(x: 1, y: 1),
                        velocityForTranslation: velocityForAnimation,
                        velocityForScaling: velocityForScaling
                      )

                    let interpolationViewStyleAnimator = UIViewPropertyAnimator(
                      duration: 0.85,
                      dampingRatio: 1
                    ) {
                      interpolationView.alpha = 1
                    }

                    animators += interpolationViewAnimators + [interpolationViewStyleAnimator]
                  }

                  Fluid.startPropertyAnimators(animators) {
                    transitionContext.notifyAnimationCompleted()
                  }
                case .shape(
                  let destinationComponent,
                  let destinationMirroViewProvider
                ):

                  AnyRemovingInteraction.Contextual.run(
                    transitionContext: transitionContext,
                    disclosedView: draggingView,
                    destinationComponent: destinationComponent,
                    destinationMirroViewProvider: destinationMirroViewProvider,
                    gestureVelocity: gesture.velocity(in: gesture.view)
                  )

                }

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

                animator.startAnimation()
              }

            case .cancelled, .failed:

              guard let _trackingContext = trackingContext else {
                return
              }

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
