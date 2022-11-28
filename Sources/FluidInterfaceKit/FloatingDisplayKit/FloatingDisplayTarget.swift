
import UIKit

public final class FloatingDisplayTarget {

  private let notificationWindow: NotificationWindow
  private let notificationViewController = NotificationViewController()

  public var additionalSafeAreaInsets: UIEdgeInsets {
    get { notificationViewController.additionalSafeAreaInsets }
    set { notificationViewController.additionalSafeAreaInsets = newValue }
  }

  public var windowLevel: UIWindow.Level {
    get {
      return notificationWindow.windowLevel
    }
    set {
      notificationWindow.windowLevel = newValue
    }
  }

  public var contentView: UIView {
    notificationViewController.view
  }

  public func visibleWindow() {
    notificationWindow.isHidden = false
  }

  public func hideWindow() {
    notificationWindow.isHidden = true
  }

  public init() {

    if #available(iOS 13, *) {

      let windowScene = UIApplication.shared
        .connectedScenes
        .lazy
        .filter { $0.activationState == .foregroundActive }
        .compactMap { $0 as? UIWindowScene }
        .first

      if let windowScene = windowScene {
        notificationWindow = .init(windowScene: windowScene)
      } else {
        notificationWindow = .init(frame: .zero)
      }

    } else {
      notificationWindow = .init(frame: .zero)
    }

    notificationWindow.windowLevel = UIWindow.Level(rawValue: 5)
    notificationWindow.isHidden = true
    notificationWindow.backgroundColor = UIColor.clear
    notificationWindow.frame = UIScreen.main.bounds
    notificationViewController.beginAppearanceTransition(true, animated: false)
    notificationWindow.rootViewController = notificationViewController
    notificationViewController.endAppearanceTransition()
  }

  deinit {
    notificationWindow.isHidden = true
  }

}

extension FloatingDisplayTarget {

  fileprivate class NotificationWindow: UIWindow {

    override init(frame: CGRect) {
      super.init(frame: frame)
      isOpaque = false
    }

    @available(iOS 13.0, *)
    override init(windowScene: UIWindowScene) {
      super.init(windowScene: windowScene)
      isOpaque = false
    }

    required init?(coder _: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
      let view = super.hitTest(point, with: event)

      if view == self {
        return nil
      }
      return view
    }
  }

  fileprivate final class NotificationViewController: UIViewController {
    override fileprivate func loadView() {
      view = View()
    }

    override fileprivate func viewDidLoad() {
      super.viewDidLoad()
      view.isOpaque = false
      view.backgroundColor = UIColor.clear
    }

    fileprivate class View: UIView {
      override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)

        if view == self {
          return nil
        }
        return view
      }
    }
  }

}
