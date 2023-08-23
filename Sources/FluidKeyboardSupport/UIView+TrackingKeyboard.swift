
import UIKit

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

