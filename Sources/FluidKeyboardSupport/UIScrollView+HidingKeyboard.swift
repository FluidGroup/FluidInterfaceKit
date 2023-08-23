import UIKit

fileprivate var ref: Void?

extension UIScrollView {

  /**
   The pan gesture tracks the location to determine whether it is on or off the keyboard.
   When the location falls within the keyboard's boundaries, it hides the keyboard.
   */
  @available(iOS 15, *)
  @MainActor
  public func setKeyboardSwipeDownOffscreenGesture(isActive: Bool) {
    if isActive {
      let newCoordinator = PanGestureCoordinator(scrollView: self, panGesture: UIPanGestureRecognizer())
      self.coordinator = newCoordinator
    } else {
      self.coordinator = nil
    }
  }

  @available(iOS 15, *)
  @MainActor
  private var coordinator: PanGestureCoordinator? {
    get { objc_getAssociatedObject(self, &ref) as? PanGestureCoordinator }
    set { objc_setAssociatedObject(self, &ref, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }

}

@available(iOS 15, *)
@MainActor
private final class PanGestureCoordinator: NSObject, UIGestureRecognizerDelegate {

  private let scrollView: UIScrollView
  private let panGesture: UIPanGestureRecognizer

  init(scrollView: UIScrollView, panGesture: UIPanGestureRecognizer) {
    self.scrollView = scrollView
    self.panGesture = panGesture
    super.init()
    panGesture.delegate = self
    panGesture.addTarget(self, action: #selector(handlePanGesture(_:)))

    scrollView.addGestureRecognizer(panGesture)
  }

  deinit {
    Task { @MainActor [scrollView, panGesture] in
      scrollView.removeGestureRecognizer(panGesture)
    }
  }

  @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {

    guard let view = gesture.view else {
      assertionFailure()
      return
    }

    let location = gesture.location(in: view)

    switch gesture.state {
    case .began, .changed:

      if location.y > view.keyboardLayoutGuide.layoutFrame.minY {
        view.endEditing(true)
      }

    case .ended:
      break
    default:
      break
    }

  }

  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }

  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }

}
