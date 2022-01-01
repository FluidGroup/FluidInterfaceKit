import GeometryKit
import MatchedTransition
import ResultBuilderKit
import UIKit

public struct AnyRemovingInteraction {

  public struct Context {
    public let viewController: InteractiveRemovingViewController
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

  // FIXME: not completed
  public static func leftToRight(
    dismiss: @escaping (InteractiveRemovingViewController) -> Void
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

  public enum BackwardingMode {
    // TODO: get a generic name
    case instagramThreads(destinationView: UIView, interpolationView: UIView)
    case shape(destinationView: UIView)
  }

  /**
   Instagram Threads like transition
   */
  public static func horizontalDragging(
    backwardingMode: BackwardingMode?,
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

                let transitionContext =
                  context.viewController.zStackViewControllerContext?.startRemoving()
                  ?? context.viewController._startStandaloneRemovingTransition()

                BatchApplier(hidingViews).setInvisible(true)

                transitionContext.addEventHandler { event in
                  BatchApplier(hidingViews).setInvisible(false)
                  gesture.view!.layer.cornerRadius = 0
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
                    _trackingContext.transitionContext.notifyCompleted()
                  }

                  animator.startAnimation()

                  return
                }

                switch backwardingMode {
                case .instagramThreads(let destinationView, let interpolationView):

                  var targetRect = Geometry.rectThatAspectFit(
                    aspectRatio: draggingView.bounds.size,
                    boundingRect: transitionContext.frameInContentView(for: destinationView)
                  )

                  targetRect = targetRect.insetBy(
                    dx: targetRect.width / 3,
                    dy: targetRect.height / 3
                  )

                  let translation = makeTranslation(from: draggingView.bounds, to: targetRect)

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
                        scale: .init(width: 1, height: 1),
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
                    _trackingContext.transitionContext.notifyCompleted()
                  }
                case .shape(let destinationView):

                  let maskView = UIView()
                  maskView.backgroundColor = .black

                  maskView.frame = transitionContext.fromViewController.view.bounds
                  transitionContext.fromViewController.view.mask = maskView

                  let entrypointSnapshotView = Fluid.takeSnapshotVisible(view: destinationView)

                  transitionContext.contentView.addSubview(entrypointSnapshotView)
                  entrypointSnapshotView.frame = .init(origin: draggingView.frame.origin, size: destinationView.bounds.size)
                  entrypointSnapshotView.alpha = 0

                  _trackingContext.transitionContext.addEventHandler { _ in
                    entrypointSnapshotView.removeFromSuperview()
                  }

                  let translation = makeTranslation(
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

                  let animators = Fluid.makePropertyAnimatorsForTranformUsingCenter(
                    view: transitionContext.fromViewController.view,
                    duration: 0.8,
                    position: .custom(translation.center),
                    scale: translation.scale,
                    velocityForTranslation: velocityForAnimation,
                    velocityForScaling: .zero
                  )

                  let backgroundAnimator = UIViewPropertyAnimator(duration: 0.6, dampingRatio: 1) {
                    _trackingContext.transitionContext.contentView.backgroundColor = .clear
                  }

                  let snapshotAnimator = UIViewPropertyAnimator(duration: 0.6, dampingRatio: 1) {
                    transitionContext.fromViewController.view.alpha = 0
                    entrypointSnapshotView.frame = transitionContext.frameInContentView(for: destinationView)
                    entrypointSnapshotView.alpha = 1
                  }

                  let maskViewAnimator = UIViewPropertyAnimator(duration: 0.6, dampingRatio: 1) {
                    maskView.frame = transitionContext.fromViewController.view.bounds
                    maskView.frame.size.height = destinationView.bounds.height / translation.scale.height
                    maskView.layer.cornerRadius = 24
                    if #available(iOS 13.0, *) {
                      maskView.layer.cornerCurve = .continuous
                    } else {
                      // Fallback on earlier versions
                    }
                  }

                  Fluid.startPropertyAnimators(
                    buildArray {
                      animators
                      backgroundAnimator
                      maskViewAnimator
                      snapshotAnimator
                    },
                    completion: {
                      transitionContext.notifyCompleted()
                    }
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
        )
      ]
    )
  }
}
