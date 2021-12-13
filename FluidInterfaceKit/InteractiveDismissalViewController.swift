//
// Copyright (c) 2021 Copyright (c) 2021 Eureka, Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import UIKit

open class InteractiveDismissalViewController: UIViewController, UIGestureRecognizerDelegate {

  // MARK: - Properties

  public override var childForStatusBarStyle: UIViewController? {
    return bodyViewController
  }

  public override var childForStatusBarHidden: UIViewController? {
    return bodyViewController
  }

  public let bodyViewController: UIViewController?

  @available(*, unavailable, message: "Unsupported")
  open override var navigationController: UINavigationController? {
    super.navigationController
  }

  public var interactiveUnwindGestureRecognizer: UIPanGestureRecognizer?

  public var interactiveEdgeUnwindGestureRecognizer: UIScreenEdgePanGestureRecognizer?

  private var registeredGestures: [UIGestureRecognizer] = []

  private let customView: UIView?

  private var interaction: AnyInteraction?

  // MARK: - Initializers

  /// Creates an instance
  ///
  /// - Parameters:
  ///   - idiom:
  ///   - bodyViewController: a view controller that displays as a child view controller. It helps a case of can't create a subclass of FluidViewController.
  public init(
    bodyViewController: UIViewController,
    interaction: AnyInteraction? = nil
  ) {
    self.interaction = interaction
    self.bodyViewController = bodyViewController
    self.customView = nil
    super.init(nibName: nil, bundle: nil)
  }

  public init(
    view: UIView,
    interaction: AnyInteraction? = nil
  ) {

    self.interaction = interaction
    self.bodyViewController = nil
    self.customView = view
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  public required init?(
    coder: NSCoder
  ) {
    fatalError()
  }

  // MARK: - Functions

  open override func loadView() {
    if let customView = customView {
      view = customView
    } else {
      super.loadView()
    }
  }

  open override func viewDidLoad() {
    super.viewDidLoad()

    setupGestures()

    if let bodyViewController = bodyViewController {
      addChild(bodyViewController)
      view.addSubview(bodyViewController.view)
      bodyViewController.view.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        bodyViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
        bodyViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
        bodyViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
        bodyViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      ])
      bodyViewController.didMove(toParent: self)
    }
  }

  public func setInteraction(_ newInteraction: AnyInteraction) {
    interaction = newInteraction
    setupGestures()
  }

  private func setupGestures() {

    registeredGestures.forEach {
      view.removeGestureRecognizer($0)
    }
    registeredGestures = []

    guard let interaction = interaction else {
      return
    }

    for handler in interaction.handlers {
      switch handler {
      case .leftEdge:
        let edgeGesture = _EdgePanGestureRecognizer(target: self, action: #selector(handleEdgeLeftPanGesture))
        edgeGesture.edges = .left
        view.addGestureRecognizer(edgeGesture)
        edgeGesture.delegate = self
        self.interactiveEdgeUnwindGestureRecognizer = edgeGesture
        registeredGestures.append(edgeGesture)
      case .screen:
        let panGesture = _PanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        view.addGestureRecognizer(panGesture)
        panGesture.delegate = self
        self.interactiveUnwindGestureRecognizer = panGesture

        registeredGestures.append(panGesture)
      }
    }
  }

  @objc
  private func handleEdgeLeftPanGesture(_ gesture: _EdgePanGestureRecognizer) {

    guard let interaction = interaction else {
      return
    }

    for handler in interaction.handlers {
      if case .leftEdge(let handler) = handler {

        handler(gesture, .init(viewController: self))

      }
    }

  }

  @objc
  private func handlePanGesture(_ gesture: _PanGestureRecognizer) {

    guard let interaction = interaction else {
      return
    }

    for handler in interaction.handlers {
      if case .screen(let handler) = handler {
        handler(gesture, .init(viewController: self))
      }
    }

  }

  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {

    if gestureRecognizer is UIScreenEdgePanGestureRecognizer {

      return (otherGestureRecognizer is UIScreenEdgePanGestureRecognizer) == false
    }

    return true
  }

}

public struct AnyInteraction {

  public struct Context {
    public let viewController: InteractiveDismissalViewController
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

extension AnyInteraction {

  public static func leftToRight() -> Self {

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

                let currentTransform = view.layer.presentation().map {
                  CATransform3DGetAffineTransform($0.transform)
                } ?? .identity

                view.transform = currentTransform

                let animator = UIViewPropertyAnimator(duration: 0.62, dampingRatio: 1) {
                  view.transform = currentTransform.translatedBy(x: view.bounds.width * 1.3, y: 0)
                }

                animator.addCompletion { position in
                  switch position {
                  case .end:
                    context.viewController.zStackViewControllerContext?.removeSelf(transition: nil)
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

  public static func horizontalDragging(backTo destinationCoordinateSpace: UICoordinateSpace) -> Self {

    struct TrackingContext {

      var scrollController: ScrollController?
      let viewFrame: CGRect
      let beganPoint: CGPoint

      func normalizedVelocity(gesture: UIPanGestureRecognizer) -> CGVector {
        let velocity = gesture.velocity(in: gesture.view)
        let screenBounds = UIScreen.main.bounds
        return .init(dx: velocity.x / screenBounds.width, dy: velocity.y / screenBounds.height)
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

                if abs(gesture.translation(in: view).y) > 10 {
                  gesture.state = .failed
                  return
                }

                /**
                 Prepare to interact
                 */

                let currentTransform = view.layer.presentation().map {
                  CATransform3DGetAffineTransform($0.transform)
                } ?? .identity

                view.transform = currentTransform

                var newTrackingContext = TrackingContext(
                  scrollController: nil,
                  viewFrame: view.bounds,
                  beganPoint: gesture.location(in: view)
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

              if let _ = trackingContext {

                let translation = gesture.translation(in: gesture.view)
                gesture.view!.center.x += translation.x
                gesture.view!.center.y += translation.y

                gesture.view!.layer.cornerRadius = 24
                if #available(iOS 13.0, *) {
                  gesture.view!.layer.cornerCurve = .continuous
                } else {
                  // Fallback on earlier versions
                }

                gesture.setTranslation(.zero, in: gesture.view)
              }

            case .ended:

              guard let _trackingContext = trackingContext else {
                return
              }

              _trackingContext.scrollController?.unlockScrolling()
              _trackingContext.scrollController?.endTracking()

              let velocity = gesture.velocity(in: gesture.view)

              let originalCenter = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
              let distanceFromCenter = CGPoint(x: view.center.x - originalCenter.x, y: view.center.y - originalCenter.y)

              if abs(distanceFromCenter.x) > 80 || abs(distanceFromCenter.y) > 80 || abs(velocity.x) > 50 || abs(velocity.y) > 50 {

                if let containerView = context.viewController.zStackViewControllerContext?.zStackViewController?.view {

                  let animator = UIViewPropertyAnimator(
                    duration: 0.4,
                    timingParameters: UISpringTimingParameters(
                      dampingRatio: 1,
                      initialVelocity: _trackingContext.normalizedVelocity(gesture: gesture)
                    )
                  )

                  var targetRect = rectThatAspectFit(
                    aspectRatio: view.bounds.size,
                    boundingRect: destinationCoordinateSpace.convert(destinationCoordinateSpace.bounds, to: containerView)
                  )

                  targetRect = targetRect.insetBy(dx: targetRect.width / 2, dy: targetRect.height / 2)
                  targetRect.size = .init(width: 1, height: 1)

                  animator.addAnimations {
                    view.center = .init(x: view.bounds.width / 2, y: view.bounds.height / 2)
                    view.transform = makeCGAffineTransform(from: view.bounds, to: targetRect)
                  }

                  animator.addCompletion { _ in
                    context.viewController.zStackViewControllerContext?.removeSelf(transition: nil)
                    view.transform = .identity
                  }

                  animator.startAnimation()
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
                    view.transform = .init(scaleX: 0.8, y: 0.8)
                    view.alpha = 0
                  }

                  animator.addCompletion { _ in
                    context.viewController.zStackViewControllerContext?.removeSelf(transition: nil)
                    view.transform = .identity
                    view.alpha = 1
                  }

                  animator.startAnimation()
                }


              } else {

                let animator = UIViewPropertyAnimator(
                  duration: 0.62,
                  timingParameters: UISpringTimingParameters(
                    dampingRatio: 1,
                    initialVelocity: _trackingContext.normalizedVelocity(gesture: gesture)
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

final class _EdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer {

  weak var trackingScrollView: UIScrollView?

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
    trackingScrollView = event.findScrollView()
    super.touchesBegan(touches, with: event)
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {

    super.touchesMoved(touches, with: event)
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
    super.touchesEnded(touches, with: event)
  }

  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
    super.touchesCancelled(touches, with: event)
  }

}

public final class _PanGestureRecognizer: UIPanGestureRecognizer {

  public private(set) weak var trackingScrollView: UIScrollView?

  public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
    trackingScrollView = event.findScrollView()
    super.touchesBegan(touches, with: event)
  }

  public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {

    super.touchesMoved(touches, with: event)
  }

  public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
    super.touchesEnded(touches, with: event)
  }

  public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
    super.touchesCancelled(touches, with: event)
  }

}

extension UIEvent {

  fileprivate func findScrollView() -> UIScrollView? {

    guard
      let firstTouch = allTouches?.first,
      let targetView = firstTouch.view
    else { return nil }

    let scrollView = sequence(first: targetView, next: \.next).map { $0 }
      .first {
        guard let scrollView = $0 as? UIScrollView else {
          return false
        }

        func isScrollable(scrollView: UIScrollView) -> Bool {

          let contentInset: UIEdgeInsets

          if #available(iOS 11.0, *) {
            contentInset = scrollView.adjustedContentInset
          } else {
            contentInset = scrollView.contentInset
          }

          return (scrollView.bounds.width - (contentInset.right + contentInset.left) <= scrollView.contentSize.width) || (scrollView.bounds.height - (contentInset.top + contentInset.bottom) <= scrollView.contentSize.height)
        }

        return isScrollable(scrollView: scrollView)
      }

    return (scrollView as? UIScrollView)
  }

}
