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
import MatchedTransition

open class InteractiveDismissalTransitionViewController: TransitionViewController, UIGestureRecognizerDelegate, ViewControllerZStackContentType {

  // MARK: - Properties

  @available(*, unavailable, message: "Unsupported")
  open override var navigationController: UINavigationController? {
    super.navigationController
  }

  public var interactiveUnwindGestureRecognizer: UIPanGestureRecognizer?

  public var interactiveEdgeUnwindGestureRecognizer: UIScreenEdgePanGestureRecognizer?

  private var registeredGestures: [UIGestureRecognizer] = []

  private var interaction: AnyInteraction?

  // MARK: - Initializers

  /// Creates an instance
  ///
  /// - Parameters:
  ///   - idiom:
  ///   - bodyViewController: a view controller that displays as a child view controller. It helps a case of can't create a subclass of FluidViewController.
  public init(
    bodyViewController: UIViewController,
    transition: TransitionPair,
    interaction: AnyInteraction? = nil
  ) {
    self.interaction = interaction
    super.init(bodyViewController: bodyViewController, transition: transition)
  }

  public init(
    view: UIView,
    transition: TransitionPair,
    interaction: AnyInteraction? = nil
  ) {

    self.interaction = interaction
    super.init(view: view, transition: transition)
  }

  @available(*, unavailable)
  public required init?(
    coder: NSCoder
  ) {
    fatalError()
  }

  // MARK: - Functions

  open override func viewDidLoad() {
    super.viewDidLoad()

    setupGestures()  
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
