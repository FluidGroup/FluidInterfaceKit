import UIKit

open class FluidSheetViewController: FluidTransitionViewController {
  
  public enum Content {
    case viewController(UIViewController)
    case view(UIView)
  }
  
  public let contentView: UIView = .init()
  
  private let __content: Content?

  public init(
    content: Content? = nil,
    addingTransition: AnyAddingTransition? = nil,
    removingTransition: AnyRemovingTransition? = nil
  ) {
    
    self.__content = content

    super.init(
      content: nil,
      addingTransition: addingTransition,
      removingTransition: removingTransition
    )
    
  }
  
  open override func viewDidLoad() {
    super.viewDidLoad()
    
    
    
  }
}
