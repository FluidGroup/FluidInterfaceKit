import UIKit
import ResultBuilderKit

/**
 A view controller that aims to display on ``FluidStackController``.
 This view controller displays a content view controller as floating.
 */
open class FluidPopoverViewController: FluidGestureHandlingViewController {
  
  public enum DisplayContent {
    case view(UIView)
    case viewController(UIViewController)
  }
  
  public let foregroundViewController: UIViewController
  public let backgroundViewController: UIViewController?
  public let contentInset: UIEdgeInsets
  public let sourceCodeLocation: FluidSourceCodeLocation
      
  /// - Parameters:
  ///   - foreground: A content that displays on foreground with floating-centered layout.
  ///   - background: A content that display on background with full-screen layout.
  public init(
    foreground: DisplayContent,
    background: DisplayContent? = nil,
    contentInset: UIEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8),
    file: StaticString = #filePath,
    line: UInt = #line
  ) {
      
    self.sourceCodeLocation = .init(file: file, line: line)
    self.contentInset = contentInset
    
    switch foreground {
    case .view(let view):
      self.foregroundViewController = FluidWrapperViewController(content: .init(view: view))
    case .viewController(let viewController):
      assert((viewController is FluidViewController) == false, "contentViewController\(viewController) must not be FluidViewController.")
      self.foregroundViewController = viewController
    }
    
    if let background = background {
      switch background {
      case .view(let view):
        self.backgroundViewController = FluidWrapperViewController(content: .init(view: view))
      case .viewController(let viewController):
        assert((viewController is FluidViewController) == false, "contentViewController\(viewController) must not be FluidViewController.")
        self.backgroundViewController = viewController
      }
    } else {
      self.backgroundViewController = nil
    }
    
    super.init(
      content: nil,
      addingTransition: .popoverBasic,
      removingTransition: .popoverFadeout,
      removingInteraction: nil
    )
    
  }
  
  open override func viewDidLoad() {
    super.viewDidLoad()
    
    fluidStackContentConfiguration.contentType = .overlay
    fluidStackContentConfiguration.capturesStatusBarAppearance = false
    
    // background
    if let backgroundViewController = backgroundViewController {
            
      let contentView = backgroundViewController.view!
      addChild(backgroundViewController)
      view.addSubview(contentView)
      foregroundViewController.didMove(toParent: self)
      
      contentView.translatesAutoresizingMaskIntoConstraints = false
      
      NSLayoutConstraint.activate(buildArray {
        
        contentView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0)
        
        contentView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0)
        
        contentView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0)
        
        contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        
      })
      
    }
    
    // foreground
    do {
      let contentView = foregroundViewController.view!
      addChild(foregroundViewController)
      view.addSubview(contentView)
      foregroundViewController.didMove(toParent: self)
      
      contentView.translatesAutoresizingMaskIntoConstraints = false
      
      NSLayoutConstraint.activate(buildArray {
        
        contentView.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: contentInset.top)
        
        contentView.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: contentInset.left)
        
        contentView.rightAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: -contentInset.right)
        
        contentView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -contentInset.bottom)
        
        contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        
      })
      
    }
        
   
  }
  
}

extension AnyAddingTransition {
  
  /// For ``FluidPopoverViewController``
  public static var popoverBasic: Self {
    .throwing(
      backup: .fadeIn(),
      startTransition: { context in
        
        guard let toViewController = context.toViewController as? FluidPopoverViewController else {
          assertionFailure("This transition is optimized for FluidPopoverViewController.")
          throw TransitionContext.Error.missingRequiredValue
        }
        
        let content = toViewController.foregroundViewController
        
        content.view.alpha = 0
        content.view.transform = .init(scaleX: 1.2, y: 1.2)
        
        let animator = UIViewPropertyAnimator(duration: 0.4, dampingRatio: 1) {
          content.view.alpha = 1
          content.view.transform = .identity
        }
        
        animator.addCompletion { _ in
          context.notifyAnimationCompleted()
        }

        animator.startAnimation()
        
      }
    )
  }
}

extension AnyRemovingTransition {
  
  /// For ``FluidPopoverViewController``
  public static var popoverFadeout: Self {
    .throwing(
      backup: .fadeOut(),
      startTransition: { context in
        
        guard let fromViewController = context.fromViewController as? FluidPopoverViewController else {
          assertionFailure("This transition is optimized for FluidPopoverViewController.")
          throw TransitionContext.Error.missingRequiredValue
        }
        
        let content = fromViewController.foregroundViewController
        
        let animator = UIViewPropertyAnimator(duration: 0.4, dampingRatio: 1) {
          content.view.alpha = 0
        }
        
        animator.addCompletion { _ in
          context.notifyAnimationCompleted()
        }

        animator.startAnimation()
        
      }
    )
  }
  
}
