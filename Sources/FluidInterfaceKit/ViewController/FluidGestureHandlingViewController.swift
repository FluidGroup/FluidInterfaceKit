import Foundation
import UIKit

/**
 A view controller that supports interaction to start removing transiton.
 It works as a wrapper for another view controller or using with subclassing.
 If you have already implementation of view controller and want to get flexibility, you can use this class as a wrapper.
 
 ```swift
 let yourController = YourViewController()
 
 let fluidController = FluidViewController(
   bodyViewController: yourController,
   ...
 )
 ```
 
 You may specify ``AnyRemovingInteraction``
 */
open class FluidGestureHandlingViewController: FluidTransitionViewController, UIGestureRecognizerDelegate {

  // MARK: - Properties

  @available(*, unavailable, message: "Unsupported")
  open override var navigationController: UINavigationController? {
    super.navigationController
  }

  public private(set) lazy var fluidPanGesture: FluidPanGestureRecognizer = FluidPanGestureRecognizer(
    target: self,
    action: #selector(handlePanGesture)
  )

  public private(set) lazy var fluidScreenEdgePanGesture: UIScreenEdgePanGestureRecognizer = _EdgePanGestureRecognizer(
    target: self,
    action: #selector(handleEdgeLeftPanGesture)
  )

  private var registeredGestures: [UIGestureRecognizer] = []

  public var removingInteraction: AnyRemovingInteraction? {
    didSet {
      guard isViewLoaded else { return }
      setupGestures()
    }
  }

  // MARK: - Initializers

  public init(
    content: FluidWrapperViewController.Content?,
    addingTransition: AnyAddingTransition?,
    removingTransition: AnyRemovingTransition?,
    removingInteraction: AnyRemovingInteraction?
  ) {
    self.removingInteraction = removingInteraction
    super.init(
      content: content,
      addingTransition: addingTransition,
      removingTransition: removingTransition
    )
  }
  
  deinit {
    Log.debug(.fluidController, "Deinit \(self)")
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

  private func setupGestures() {
    
    assert(Thread.isMainThread)

    registeredGestures.forEach {
      view.removeGestureRecognizer($0)
    }
    registeredGestures = []

    guard let interaction = removingInteraction else {
      return
    }

    for handler in interaction.handlers {
      switch handler {
      case .gestureOnLeftEdge:
        
        let created = fluidScreenEdgePanGesture
                       
        created.edges = .left
        
        view.addGestureRecognizer(created)
        created.delegate = self
        registeredGestures.append(created)
      case .gestureOnScreen:
        
        let created = fluidPanGesture
        
        view.addGestureRecognizer(created)
        created.delegate = self
        registeredGestures.append(created)
      }
    }
    
    fluidPanGesture.require(toFail: fluidScreenEdgePanGesture)
      
  }

  @objc
  private func handleEdgeLeftPanGesture(_ gesture: _EdgePanGestureRecognizer) {

    guard let interaction = removingInteraction else {
      return
    }

    for handler in interaction.handlers {
      if case .gestureOnLeftEdge(_, let handler) = handler {

        handler(gesture, .init(viewController: self))

      }
    }

  }

  @objc
  private func handlePanGesture(_ gesture: FluidPanGestureRecognizer) {

    guard let removingInteraction = removingInteraction else {
      return
    }

    for handler in removingInteraction.handlers {
      if case .gestureOnScreen(_, let handler) = handler {
        handler(gesture, .init(viewController: self))
      }
    }

  }
  
  public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    
    switch gestureRecognizer {
    case fluidPanGesture:
      
      if let removingInteraction = removingInteraction {
        for handler in removingInteraction.handlers {
          if case .gestureOnScreen(let condition, _) = handler {
            
            var resultPlaceholder: Bool = false
            
            condition(
              fluidPanGesture, .shouldBeRequiredToFailBy(
                otherGestureRecognizer: otherGestureRecognizer,
                completion: { result in
                  // non-escaping
                  resultPlaceholder = result
                }
              )
            )
            
            return resultPlaceholder

          }
        }
      }
    
    case fluidScreenEdgePanGesture:
      
      if let removingInteraction = removingInteraction {
        for handler in removingInteraction.handlers {
          if case .gestureOnLeftEdge(let condition, _) = handler {
            
            var resultPlaceholder: Bool = false
            
            condition(
              fluidScreenEdgePanGesture,
              .shouldBeRequiredToFailBy(
                otherGestureRecognizer: otherGestureRecognizer,
                completion: { result in
                  // non-escaping
                  resultPlaceholder = result
                }
              )
            )
            
            return resultPlaceholder
            
          }
        }
      }
      
    default:
      break
    }
    
    return false

  }
  
  public func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
  ) -> Bool {
    
    switch gestureRecognizer {
    case fluidPanGesture:
  
      if let removingInteraction = removingInteraction {
        for handler in removingInteraction.handlers {
          if case .gestureOnScreen(let condition, _) = handler {
            
            var resultPlaceholder: Bool = false
            
            condition(
              fluidPanGesture, .shouldRecognizeSimultaneouslyWith(
                otherGestureRecognizer: otherGestureRecognizer,
                completion: { result in
                  // non-escaping
                  resultPlaceholder = result
                }
              )
            )
            
            return resultPlaceholder
            
          }
        }
      }
      
    case fluidScreenEdgePanGesture:
                
      if let removingInteraction = removingInteraction {
        for handler in removingInteraction.handlers {
          if case .gestureOnLeftEdge(let condition, _) = handler {
            
            var resultPlaceholder: Bool = false
            
            condition(
              fluidScreenEdgePanGesture,
              .shouldRecognizeSimultaneouslyWith(
                otherGestureRecognizer: otherGestureRecognizer,
                completion: { result in
                  // non-escaping
                  resultPlaceholder = result
                }
              )
            )
            
            return resultPlaceholder
            
          }
        }
      }
      
    default:
      break
    }
    return true
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

public final class FluidPanGestureRecognizer: UIPanGestureRecognizer {

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

          return
            (scrollView.bounds.width - (contentInset.right + contentInset.left)
            <= scrollView.contentSize.width)
            || (scrollView.bounds.height - (contentInset.top + contentInset.bottom)
              <= scrollView.contentSize.height)
        }

        return isScrollable(scrollView: scrollView)
      }

    return (scrollView as? UIScrollView)
  }

}
