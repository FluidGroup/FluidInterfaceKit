import FluidCore
import UIKit

@MainActor
public final class FloatingDisplayTarget {

  public struct EdgeTargetSafeArea {

    public let top: TargetSafeArea
    public let right: TargetSafeArea
    public let bottom: TargetSafeArea
    public let left: TargetSafeArea

    public init(
      top: TargetSafeArea,
      right: TargetSafeArea,
      bottom: TargetSafeArea,
      left: TargetSafeArea
    ) {
      self.top = top
      self.right = right
      self.bottom = bottom
      self.left = left
    }

    public static var notificationWindow: Self {
      Self.init(
        top: .notificationWindow,
        right: .notificationWindow,
        bottom: .notificationWindow,
        left: .notificationWindow
      )
    }

    public static var activeWindow: Self {
      Self.init(
        top: .activeWindow,
        right: .activeWindow,
        bottom: .activeWindow,
        left: .activeWindow
      )
    }

    fileprivate var containsActiveWindowEdge: Bool {
      top == .activeWindow
        || right == .activeWindow
        || bottom == .activeWindow
        || left == .activeWindow
    }
  }

  public enum TargetSafeArea: Equatable {
    case notificationWindow
    case activeWindow
  }

  private let notificationWindow: NotificationWindow
  private let safeAreaFinder: SafeAreaFinder
  private let notificationViewController: NotificationViewController

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

  public func makeWindowVisible() {
    _ = notificationViewController.view
    notificationWindow.isHidden = false

    if notificationViewController.needsActiveWindowSafeArea {
      safeAreaFinder.start()
    }
  }

  public func hideWindow() {
    notificationWindow.isHidden = true
    safeAreaFinder.stop()
  }

  @available(iOS 13.0, *)
  public init(
    edgeTargetSafeArea: EdgeTargetSafeArea,
    windowScene: UIWindowScene
  ) {

    self.safeAreaFinder = .init(windowScene: windowScene)
    self.notificationViewController = .init(
      edgeTargetSafeArea: edgeTargetSafeArea,
      safeAreaFinder: safeAreaFinder
    )
    self.notificationWindow = .init(windowScene: windowScene)

    notificationWindow.windowLevel = UIWindow.Level(rawValue: 5)
    notificationWindow.isHidden = true
    notificationWindow.backgroundColor = UIColor.clear
    notificationWindow.frame = UIScreen.main.bounds
    notificationViewController.beginAppearanceTransition(true, animated: false)
    notificationWindow.rootViewController = notificationViewController
    notificationViewController.endAppearanceTransition()
  }

  deinit {
    Task { @MainActor [safeAreaFinder, notificationWindow] in
      safeAreaFinder.stop()
      notificationWindow.isHidden = false
    }
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

    private let edgeTargetSafeArea: EdgeTargetSafeArea
    private let safeAreaFinder: SafeAreaFinder

    fileprivate var needsActiveWindowSafeArea: Bool {
      edgeTargetSafeArea.containsActiveWindowEdge
    }

    init(
      edgeTargetSafeArea: EdgeTargetSafeArea,
      safeAreaFinder: SafeAreaFinder
    ) {
      self.edgeTargetSafeArea = edgeTargetSafeArea
      self.safeAreaFinder = safeAreaFinder
      super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override fileprivate func loadView() {
      view = View(
        edgeTargetSafeArea: edgeTargetSafeArea,
        safeAreaFinder: safeAreaFinder
      )
    }

    override fileprivate func viewDidLoad() {
      super.viewDidLoad()
      view.isOpaque = false
      view.backgroundColor = UIColor.clear
    }

    fileprivate class View: UIView {

      private let edgeTargetSafeArea: EdgeTargetSafeArea
      private let safeAreaFinder: SafeAreaFinder

      private var _safeAreaLayoutGuide: UILayoutGuide = .init()
      private var activeWindowSafeAreaLayoutGuideConstraintLeft: NSLayoutConstraint?
      private var activeWindowSafeAreaLayoutGuideConstraintRight: NSLayoutConstraint?
      private var activeWindowSafeAreaLayoutGuideConstraintTop: NSLayoutConstraint?
      private var activeWindowSafeAreaLayoutGuideConstraintBottom: NSLayoutConstraint?

      private var hasSafeAreaFinderActivated: Bool = false

      init(
        edgeTargetSafeArea: EdgeTargetSafeArea,
        safeAreaFinder: SafeAreaFinder
      ) {

        self.edgeTargetSafeArea = edgeTargetSafeArea
        self.safeAreaFinder = safeAreaFinder

        super.init(frame: .zero)

        addLayoutGuide(_safeAreaLayoutGuide)

        var containsActiveWindowSafeAreaEdge: Bool = false

        switch edgeTargetSafeArea.top {
        case .notificationWindow:
          _safeAreaLayoutGuide.topAnchor.constraint(equalTo: super.safeAreaLayoutGuide.topAnchor)
            .isActive = true
        case .activeWindow:
          activeWindowSafeAreaLayoutGuideConstraintTop = topAnchor.constraint(
            equalTo: _safeAreaLayoutGuide.topAnchor)
          containsActiveWindowSafeAreaEdge = true
        }

        switch edgeTargetSafeArea.right {
        case .notificationWindow:
          _safeAreaLayoutGuide.rightAnchor.constraint(
            equalTo: super.safeAreaLayoutGuide.rightAnchor
          ).isActive = true
        case .activeWindow:
          activeWindowSafeAreaLayoutGuideConstraintRight = rightAnchor.constraint(
            equalTo: _safeAreaLayoutGuide.rightAnchor)
          containsActiveWindowSafeAreaEdge = true
        }

        switch edgeTargetSafeArea.bottom {
        case .notificationWindow:
          _safeAreaLayoutGuide.bottomAnchor.constraint(
            equalTo: super.safeAreaLayoutGuide.bottomAnchor
          ).isActive = true
        case .activeWindow:
          activeWindowSafeAreaLayoutGuideConstraintBottom = bottomAnchor.constraint(
            equalTo: _safeAreaLayoutGuide.bottomAnchor)
          containsActiveWindowSafeAreaEdge = true
        }

        switch edgeTargetSafeArea.left {
        case .notificationWindow:
          _safeAreaLayoutGuide.leftAnchor.constraint(equalTo: super.safeAreaLayoutGuide.leftAnchor)
            .isActive = true
        case .activeWindow:
          activeWindowSafeAreaLayoutGuideConstraintLeft = leftAnchor.constraint(
            equalTo: _safeAreaLayoutGuide.leftAnchor)
          containsActiveWindowSafeAreaEdge = true
        }

        if containsActiveWindowSafeAreaEdge {

          NSLayoutConstraint.activate(
            [
              activeWindowSafeAreaLayoutGuideConstraintTop,
              activeWindowSafeAreaLayoutGuideConstraintRight,
              activeWindowSafeAreaLayoutGuideConstraintBottom,
              activeWindowSafeAreaLayoutGuideConstraintLeft,
            ].compactMap { $0 })

          hasSafeAreaFinderActivated = true

          NotificationCenter.default.addObserver(
            self, selector: #selector(handleInsetsUpdate), name: SafeAreaFinder.notificationName,
            object: nil)
        }
      }

      @objc private func handleInsetsUpdate(notification: Notification) {

        guard hasSafeAreaFinderActivated else { return }
        guard notification.userInfo?["finder"] as? SafeAreaFinder === safeAreaFinder else { return }

        let insets = notification.object as! UIEdgeInsets
        self.activeWindowSafeAreaLayoutGuideConstraintLeft?.constant = insets.left
        self.activeWindowSafeAreaLayoutGuideConstraintRight?.constant = insets.right
        self.activeWindowSafeAreaLayoutGuideConstraintTop?.constant = -insets.top
        self.activeWindowSafeAreaLayoutGuideConstraintBottom?.constant = insets.bottom

        setNeedsLayout()
        UIViewPropertyAnimator(duration: 0.6, dampingRatio: 1) { [self] in
          self.layoutIfNeeded()
        }
        .startAnimation()
      }

      required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
      }

      override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)

        if view == self {
          return nil
        }
        return view
      }

      override var safeAreaLayoutGuide: UILayoutGuide {
        self._safeAreaLayoutGuide
      }

      deinit {
        NotificationCenter.default.removeObserver(self)
        Task { @MainActor [safeAreaFinder] in
          safeAreaFinder.stop()
        }
      }
    }
  }

}
