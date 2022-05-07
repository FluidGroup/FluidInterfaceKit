import UIKit

open class FluidSheetViewController: FluidGestureHandlingViewController {
  
  public enum Content {
    case viewController(UIViewController)
    case view(UIView)
  }
    
  public init(
    addingTransition: AnyAddingTransition? = nil,
    removingTransition: AnyRemovingTransition? = nil
  ) {
    
    super.init(
      content: nil,
      addingTransition: addingTransition ?? .sheet,
      removingTransition: removingTransition ?? .sheet,
      removingInteraction: .sheet
    )
    
    fluidStackContentConfiguration.contentType = .overlay
    
  }
  
  open override func viewDidLoad() {
    super.viewDidLoad()
    
    
    
  }
}

extension AnyAddingTransition {
  
  public static var sheet: Self {
    return .modalStyle
  }
  
}

extension AnyRemovingTransition {
  
  public static var sheet: Self {
    return .modalStyle
  }
  
}

extension AnyRemovingInteraction {
  
  public static var sheet: Self {
    
    return .init(handlers: [
      .gestureOnScreen(handler: { gesture, context in
        
        let targetViewController = context.viewController
        let targetView = targetViewController.view!
        
        switch gesture.state {
        case .possible:
          break
        case .began, .changed:
          let translation = gesture.translation(in: nil)
          targetView.layer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(translationX: 0, y: translation.y))
          
        case .ended:
          break
        case .cancelled, .failed:
          break
        @unknown default:
          assertionFailure()
          break
        }
        
      })
    ])
    
  }
  
}
