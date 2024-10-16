import UIKit

private final class Proxy {
  @MainActor
  static var key: Void?
  private weak var base: UIControl?

  init(
    _ base: UIControl
  ) {
    self.base = base
  }

  @MainActor
  var onTouchUpInside: (@MainActor () -> Void)? {
    didSet {
      base?.addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
    }
  }

  @objc @MainActor private func touchUpInside(sender: AnyObject) {
    onTouchUpInside?()
  }
}

extension UIControl {
  
  @MainActor
  func onTap(_ closure: @escaping @MainActor () -> Swift.Void) {
    tapable.onTouchUpInside = closure
  }

  @MainActor
  private var tapable: Proxy {
    get {
      if let handler = objc_getAssociatedObject(self, &Proxy.key) as? Proxy {
        return handler
      } else {
        self.tapable = Proxy(self)
        return self.tapable
      }
    }
    set {
      objc_setAssociatedObject(self, &Proxy.key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
}

extension UIButton {

  static func make(
    title: String,
    color: UIColor? = nil,
    onTap: @escaping @MainActor () -> Void
  ) -> UIButton {
    let button = UIButton(type: .system)
    button.setAttributedTitle(
      NSAttributedString(
        string: title,
        attributes: ([
          .font: UIFont.preferredFont(forTextStyle: .headline),
          .foregroundColor : color
        ] as [NSAttributedString.Key : AnyHashable?])
          .compactMapValues { $0 }
      ),
      for: .normal
    )
    button.onTap(onTap)
    return button
  }

}
