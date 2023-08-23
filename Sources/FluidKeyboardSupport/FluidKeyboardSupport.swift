
import UIKit

public struct KeyboardFrameInfo: Equatable, Sendable {
  public var height: CGFloat

  init(height: CGFloat) {
    self.height = height
  }
}

public final class KeyboardObservation {

  private var keyValueObservation: NSKeyValueObservation
  private let onInvalidate: () -> Void

  init(keyValueObservation: NSKeyValueObservation, onInvalidate: @escaping () -> Void) {
    self.keyValueObservation = keyValueObservation
    self.onInvalidate = onInvalidate
  }

  deinit {
    keyValueObservation.invalidate()
    onInvalidate()
  }
}

extension UIView {

  @available(iOS 15, *)
  public func observeKeyboard(handler: @escaping @MainActor (KeyboardFrameInfo) -> Void) -> KeyboardObservation {

    let dummyView = UIView()
    dummyView.accessibilityIdentifier = "keyboard-dummy-view"

    addSubview(dummyView)
    dummyView.isUserInteractionEnabled = false
    dummyView.isHidden = true
    dummyView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      dummyView.topAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor),
      dummyView.bottomAnchor.constraint(equalTo: bottomAnchor),
      dummyView.leadingAnchor.constraint(equalTo: leadingAnchor),
      dummyView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])

    let token = dummyView.observe(\.bounds) { @MainActor view, _ in
      handler(.init(height: view.bounds.height))
    }

    return .init(keyValueObservation: token) { [weak dummyView] in
      Task { @MainActor in
        dummyView?.removeFromSuperview()
      }
    }

  }

}

@MainActor
private var ref: Void?

extension UIScrollView {

  @available(iOS 15, *)
  private func _observeKeyboard(handler: @escaping @MainActor (KeyboardFrameInfo) -> Void) -> KeyboardObservation {

    let dummyView = UIView()
    dummyView.accessibilityIdentifier = "keyboard-dummy-view"

    addSubview(dummyView)
    dummyView.isUserInteractionEnabled = false
    dummyView.isHidden = true
    dummyView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      dummyView.topAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor),
      dummyView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
      dummyView.leadingAnchor.constraint(equalTo: frameLayoutGuide.leadingAnchor),
      dummyView.trailingAnchor.constraint(equalTo: frameLayoutGuide.trailingAnchor),
    ])

    let token = dummyView.observe(\.bounds) { @MainActor view, _ in
      handler(.init(height: view.bounds.height))
    }

    return .init(keyValueObservation: token) { [weak dummyView] in
      Task { @MainActor in
        dummyView?.removeFromSuperview()
      }
    }

  }

  @available(iOS 15, *)
  @MainActor
  public func enableTrackingKeyboard() {

    guard keyboardObservation == nil else { return }

    keyboardObservation = self._observeKeyboard { [weak self] info in

      guard let self else { return }

      self.contentInset.bottom = info.height

    }

  }

  @MainActor
  @available(iOS 15, *)
  public func disableTrackingKeyboardHeight() {
    keyboardObservation = nil
  }

  private var keyboardObservation: KeyboardObservation? {
    get {
      objc_getAssociatedObject(self, &ref) as? KeyboardObservation
    }
    set {
      objc_setAssociatedObject(self, &ref, newValue, .OBJC_ASSOCIATION_RETAIN)
    }
  }


}

