import UIKit
import ResultBuilderKit

open class FluidPopoverViewController: FluidGestureHandlingViewController {
  
  public enum Source {
    case view(UIView)
    case viewController(UIViewController)
  }
  
  public let backgroundViewController: UIViewController?
  public let contentViewController: UIViewController
    
  public init(
    content: Source,
    background: Source? = nil
  ) {
    
    switch content {
    case .view(let view):
      self.contentViewController = FluidWrapperViewController(content: .init(view: view))
    case .viewController(let viewController):
      assert((viewController is FluidViewController) == false, "contentViewController\(viewController) must not be FluidViewController.")
      self.contentViewController = viewController
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
    
    // background
    if let backgroundViewController = backgroundViewController {
            
      let contentView = backgroundViewController.view!
      addChild(backgroundViewController)
      view.addSubview(contentView)
      contentViewController.didMove(toParent: self)
      
      contentView.translatesAutoresizingMaskIntoConstraints = false
      
      NSLayoutConstraint.activate(buildArray {
        
        contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0)
        
        contentView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0)
        
        contentView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0)
        
        contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        
      })
      
    }
    
    // foreground
    do {
      let contentView = contentViewController.view!
      addChild(contentViewController)
      view.addSubview(contentView)
      contentViewController.didMove(toParent: self)
      
      contentView.translatesAutoresizingMaskIntoConstraints = false
      
      NSLayoutConstraint.activate(buildArray {
        
        contentView.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 0)
        
        contentView.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0)
        
        contentView.rightAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0)
        
        contentView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        
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
        
        let content = toViewController.contentViewController
        
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
        
        let content = fromViewController.contentViewController
        
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