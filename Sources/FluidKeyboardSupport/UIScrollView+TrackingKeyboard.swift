import UIKit

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

    let token = dummyView.observe(\.bounds) { view, _ in
      MainActor.assumeIsolated {
        handler(.init(height: view.bounds.height))
      }
    }

    return .init(keyValueObservation: token) { [weak dummyView] in
      Task { @MainActor in
        dummyView?.removeFromSuperview()
      }
    }

  }

  /**
   It tracks the keyboard frame to set the content inset to prevent from hiding the view behind the keyboard.
   */
  @available(iOS 15, *)
  @MainActor
  public func setContentInsetAdjustmentForKeyboard(isActive: Bool) {

    if isActive {

      guard keyboardObservation == nil else { return }

      keyboardObservation = self._observeKeyboard { [weak self] info in

        guard let self else { return }

        self.contentInset.bottom = info.height

      }
    } else {
      keyboardObservation = nil
    }

  }
  
  @MainActor
  private var keyboardObservation: KeyboardObservation? {
    get {
      objc_getAssociatedObject(self, &ref) as? KeyboardObservation
    }
    set {
      objc_setAssociatedObject(self, &ref, newValue, .OBJC_ASSOCIATION_RETAIN)
    }
  }


}
