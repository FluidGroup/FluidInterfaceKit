import UIKit
import MatchedTransition
import GeometryKit

public struct AnyRemovingInteraction {

  public struct Context {
    public let viewController: InteractiveDismissalTransitionViewController
  }

  public typealias Handler<Gesture> = (Gesture, Context) -> Void

  public enum GestureHandler {
    case leftEdge(handler: Handler<UIScreenEdgePanGestureRecognizer>)
    case screen(handler: Handler<_PanGestureRecognizer>)
  }

  public let handlers: [GestureHandler]

  ///
  /// - Parameter handlers: Don't add duplicated handlers
  public init(
    handlers: [GestureHandler]
  ) {
    self.handlers = handlers
  }

  public init(
    handlers: GestureHandler...
  ) {
    self.handlers = handlers
  }

}


extension AnyRemovingInteraction {

  // FIXME: note completed
  public static func leftToRight(
    dismiss: @escaping (InteractiveDismissalTransitionViewController) -> Void
  ) -> Self {

    struct TrackingContext {

      var scrollController: ScrollController?
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
        .screen(
          handler: { gesture, context in

            let view = context.viewController.view!

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

                let animator = UIViewPropertyAnimator(duration: 0.62, dampingRatio: 1) {
                  view.transform = currentTransform.translatedBy(x: view.bounds.width * 1.3, y: 0)
                }

                animator.addCompletion { position in
                  switch position {
                  case .end:
                    dismiss(context.viewController)
                  case .start:
                    break
                  case .current:
                    assertionFailure("")
                    break
                  @unknown default:
                    assertionFailure("")
                  }
                }

                var newTrackingContext = TrackingContext(
                  scrollController: nil,
                  viewFrame: view.bounds,
                  beganPoint: gesture.location(in: view),
                  animator: animator
                )

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

              if let context = trackingContext {
                let progress = context.calulateProgress(gesture: gesture)
                context.animator.fractionComplete = progress
              }

            case .ended:

              guard let _trackingContext = trackingContext else {
                return
              }

              _trackingContext.scrollController?.unlockScrolling()
              _trackingContext.scrollController?.endTracking()

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
                UIViewPropertyAnimator(duration: 0.62, dampingRatio: 1) {
                  view.transform = .identity
                }
                .startAnimation()

              }

              trackingContext = nil

            case .cancelled, .failed:

              guard let _trackingContext = trackingContext else {
                return
              }

              _trackingContext.scrollController?.unlockScrolling()
              _trackingContext.scrollController?.endTracking()

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

  /**
   Instagram Threads like transition
   */
  public static func horizontalDragging(
    backTo destinationView: UIView?,
    interpolationView: UIView?,
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
        .screen(
          handler: { gesture, context in

            let view = context.viewController.view!
            assert(view == gesture.view)

            switch gesture.state {
            case .possible:
              break
            case .began:

              if trackingContext == nil {

                guard abs(gesture.translation(in: view).y) <= 10 else {
                  gesture.state = .failed
                  return
                }

                /**
                 Prepare to interact
                 */

                let transitionContext = context.viewController.zStackViewControllerContext?.startRemoving() ?? context.viewController._startStandaloneRemovingTransition()

                BatchApplier(hidingViews).setInvisible(true)

                transitionContext.addEventHandler { event in
                  BatchApplier(hidingViews).setInvisible(false)
                }

                // FIXME: Remove depending on ZStackViewController.
                var newTrackingContext = TrackingContext(
                  scrollController: nil,
                  transitionContext: transitionContext
                )

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

              fallthrough

            case .changed:

              guard trackingContext != nil else {
                return
              }

              let translation = gesture
                .translation(in: gesture.view)
                .applying(gesture.view!.transform)

              gesture.view!.layer.position.x += translation.x
              gesture.view!.layer.position.y += translation.y

              gesture.view!.layer.cornerRadius = 24
              gesture.view!.layer.masksToBounds = true
              if #available(iOS 13.0, *) {
                gesture.view!.layer.cornerCurve = .continuous
              } else {
                // Fallback on earlier versions
              }

              gesture.setTranslation(.zero, in: gesture.view)

            case .ended:

              guard let _trackingContext = trackingContext else {
                return
              }

              _trackingContext.scrollController?.unlockScrolling()
              _trackingContext.scrollController?.endTracking()

              let velocity = gesture.velocity(in: gesture.view)

              let originalCenter = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
              let distanceFromCenter = CGPoint(x: originalCenter.x - view.center.x, y: originalCenter.y - view.center.y)

              if abs(distanceFromCenter.x) > 80 || abs(distanceFromCenter.y) > 80 || abs(velocity.x) > 100 || abs(velocity.y) > 100 {

                // FIXME: Remove dependency to ZStackViewController
                if let destinationView = destinationView {

                  let containerView = _trackingContext.transitionContext.contentView

                  var targetRect = Geometry.rectThatAspectFit(
                    aspectRatio: view.bounds.size,
                    boundingRect: destinationView._matchedTransition_relativeFrame(
                      in: containerView,
                      ignoresTransform: false
                    )
                  )

                  targetRect = targetRect.insetBy(
                    dx: targetRect.width / 3,
                    dy: targetRect.height / 3
                  )

                  let target = makeTranslation(from: view.bounds, to: targetRect)

                  let velocityForAnimation: CGVector = {

                    let targetCenter = target.center
                    let gestureVelocity = gesture.velocity(in: gesture.view!)
                    let delta = CGPoint(x: targetCenter.x - view.center.x, y: targetCenter.y - view.center.y)

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
                    view: view,
                    duration: 0.85,
                    position: .custom(target.center),
                    scale: target.scale,
                    velocityForTranslation: velocityForAnimation,
                    velocityForScaling: velocityForScaling //sqrt(pow(velocityForAnimation.dx, 2) + pow(velocityForAnimation.dy, 2))
                  )

                  let backgroundAnimator = UIViewPropertyAnimator(duration: 0.6, dampingRatio: 1) {
                    _trackingContext.transitionContext.contentView.backgroundColor = .clear
                  }

                  animators += translationAnimators + [backgroundAnimator]

                  if let interpolationView = interpolationView {

                    interpolationView.center = .init(x: view.frame.minX, y: view.frame.minY)
                    interpolationView.transform = .init(scaleX: 0.5, y: 0.5)
                    
                    _trackingContext.transitionContext.contentView.addSubview(interpolationView)

                    let interpolationViewAnimators = Fluid.makePropertyAnimatorsForTranformUsingCenter(
                      view: interpolationView,
                      duration: 0.85,
                      position: .custom(target.center),
                      scale: .init(width: 1, height: 1),
                      velocityForTranslation: velocityForAnimation,
                      velocityForScaling: velocityForScaling
                    )

                    let interpolationViewStyleAnimator = UIViewPropertyAnimator(duration: 0.85, dampingRatio: 1) {
                      interpolationView.alpha = 1
                    }

                    animators += interpolationViewAnimators + [interpolationViewStyleAnimator]
                  }

                  Fluid.startPropertyAnimators(animators) {
                    _trackingContext.transitionContext.notifyCompleted()
                  }


                } else {
                  /// fallback

                  let animator = UIViewPropertyAnimator(
                    duration: 0.62,
                    timingParameters: UISpringTimingParameters(
                      dampingRatio: 1,
                      initialVelocity: .zero
                    )
                  )

                  animator.addAnimations {
                    view.layer.transform = CATransform3DMakeAffineTransform(.init(scaleX: 0.8, y: 0.8))
                    view.alpha = 0
                    _trackingContext.transitionContext.contentView.backgroundColor = .clear
                  }

                  animator.addCompletion { _ in
                    _trackingContext.transitionContext.notifyCompleted()
                  }

                  animator.startAnimation()

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
                  view.center = .init(x: view.bounds.width / 2, y: view.bounds.height / 2)
                  view.transform = .identity
                }

                animator.startAnimation()
              }

              trackingContext = nil

            case .cancelled, .failed:

              guard let _trackingContext = trackingContext else {
                return
              }

              _trackingContext.scrollController?.unlockScrolling()
              _trackingContext.scrollController?.endTracking()

              view.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
              view.transform = .identity
              view.layer.cornerRadius = 0

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
