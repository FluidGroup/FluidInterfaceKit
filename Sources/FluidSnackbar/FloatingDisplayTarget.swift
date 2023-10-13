
import UIKit
import FluidCore

public final class FloatingDisplayTarget {
  
  public struct EdgeTargetSafeArea {
    
    public let top: TargetSafeArea
    public let right: TargetSafeArea
    public let bottom: TargetSafeArea
    public let left: TargetSafeArea
    
    public init(top: TargetSafeArea, right: TargetSafeArea, bottom: TargetSafeArea, left: TargetSafeArea) {
      self.top = top
      self.right = right
      self.bottom = bottom
      self.left = left
    }
    
    public static let notificationWindow = Self.init(
      top: .notificationWindow,
      right: .notificationWindow,
      bottom: .notificationWindow,
      left: .notificationWindow)
    
    public static let activeWindow = Self.init(
      top: .activeWindow,
      right: .activeWindow,
      bottom: .activeWindow,
      left: .activeWindow)
  }
  
  public enum TargetSafeArea {
    case notificationWindow
    case activeWindow
  }

  private let notificationWindow: NotificationWindow
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
    notificationWindow.isHidden = false
  }

  public func hideWindow() {
    notificationWindow.isHidden = true
  }


  public init(edgeTargetSafeArea: EdgeTargetSafeArea) {
    
    self.notificationViewController = .init(edgeTargetSafeArea: edgeTargetSafeArea)

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
    
    private let edgeTargetSafeArea: EdgeTargetSafeArea

    init(edgeTargetSafeArea: EdgeTargetSafeArea) {
      self.edgeTargetSafeArea = edgeTargetSafeArea
      super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override fileprivate func loadView() {
      view = View(edgeTargetSafeArea: edgeTargetSafeArea)
    }

    override fileprivate func viewDidLoad() {
      super.viewDidLoad()
      view.isOpaque = false
      view.backgroundColor = UIColor.clear
    }

    fileprivate class View: UIView {
      
      private let edgeTargetSafeArea: EdgeTargetSafeArea
      
      private var _safeAreaLayoutGuide: UILayoutGuide = .init()
      private var activeWindowSafeAreaLayoutGuideConstraintLeft: NSLayoutConstraint?
      private var activeWindowSafeAreaLayoutGuideConstraintRight: NSLayoutConstraint?
      private var activeWindowSafeAreaLayoutGuideConstraintTop: NSLayoutConstraint?
      private var activeWindowSafeAreaLayoutGuideConstraintBottom: NSLayoutConstraint?
      
      private var hasSafeAreaFinderActivated: Bool = false

      init(edgeTargetSafeArea: EdgeTargetSafeArea) {
        
        self.edgeTargetSafeArea = edgeTargetSafeArea
        
        super.init(frame: .zero)
        
        addLayoutGuide(_safeAreaLayoutGuide)
        
        var containsActievWindowSafeAreaEdge: Bool = false
        
        switch edgeTargetSafeArea.top {
        case .notificationWindow:
          _safeAreaLayoutGuide.topAnchor.constraint(equalTo: super.safeAreaLayoutGuide.topAnchor).isActive = true
        case .activeWindow:
          activeWindowSafeAreaLayoutGuideConstraintTop = topAnchor.constraint(equalTo: _safeAreaLayoutGuide.topAnchor)
          containsActievWindowSafeAreaEdge = true
        }
        
        switch edgeTargetSafeArea.right {
        case .notificationWindow:
          _safeAreaLayoutGuide.rightAnchor.constraint(equalTo: super.safeAreaLayoutGuide.rightAnchor).isActive = true
        case .activeWindow:
          activeWindowSafeAreaLayoutGuideConstraintRight = rightAnchor.constraint(equalTo: _safeAreaLayoutGuide.rightAnchor)
          containsActievWindowSafeAreaEdge = true
        }
        
        switch edgeTargetSafeArea.bottom {
        case .notificationWindow:
          _safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: super.safeAreaLayoutGuide.bottomAnchor).isActive = true
        case .activeWindow:
          activeWindowSafeAreaLayoutGuideConstraintBottom = bottomAnchor.constraint(equalTo: _safeAreaLayoutGuide.bottomAnchor)
          containsActievWindowSafeAreaEdge = true
        }
        
        switch edgeTargetSafeArea.left {
        case .notificationWindow:
          _safeAreaLayoutGuide.leftAnchor.constraint(equalTo: super.safeAreaLayoutGuide.leftAnchor).isActive = true
        case .activeWindow:
          activeWindowSafeAreaLayoutGuideConstraintLeft = leftAnchor.constraint(equalTo: _safeAreaLayoutGuide.leftAnchor)
          containsActievWindowSafeAreaEdge = true
        }
        
        if containsActievWindowSafeAreaEdge {
          
          NSLayoutConstraint.activate([
            activeWindowSafeAreaLayoutGuideConstraintTop,
            activeWindowSafeAreaLayoutGuideConstraintRight,
            activeWindowSafeAreaLayoutGuideConstraintBottom,
            activeWindowSafeAreaLayoutGuideConstraintLeft,
          ].compactMap { $0 })
          
          hasSafeAreaFinderActivated = true
          
          NotificationCenter.default.addObserver(self, selector: #selector(handleInsetsUpdate), name: SafeAreaFinder.notificationName, object: nil)
          SafeAreaFinder.shared.start()
        }
      }

      @objc private func handleInsetsUpdate(notification: Notification) {
        
        guard hasSafeAreaFinderActivated else { return }
        
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
        if hasSafeAreaFinderActivated {
          SafeAreaFinder.shared.pause()
        }
      }
    }
  }

}
