import UIKit

extension UIView {

  func resetToVisible() {
    transform = .identity
    alpha = 1
    isHidden = false
  }

}

private var identifierRef: Void?

extension UIView {
  
  /**
   Adds an identifier to find view with ``UIView.findView``
   */
  public func addFluidViewIdentifier(_ identifier: FluidViewIdentifier) {
    
    assert(Thread.isMainThread)
    
    _identifiers.insert(identifier)
  }
  
  /**
   Removes identifiers
   */
  public func removeAllFluidViewIdentifier(where condition: (FluidViewIdentifier) -> Bool = { _ in true }) {
    
    assert(Thread.isMainThread)
        
    let deleteItems = _identifiers.filter(condition)
    _identifiers.subtract(deleteItems)
  }
  
  private var _identifiers: Set<FluidViewIdentifier> {
    get {
      objc_getAssociatedObject(self, &identifierRef) as? Set<FluidViewIdentifier> ?? .init()
    }
    set {
      objc_setAssociatedObject(self, &identifierRef, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
  }

  /**
   Finds the current first responder in this view recursively.
   */
  func currentFirstResponder() -> UIResponder? {
    if isFirstResponder{
      return self
    }

    for view in subviews {
      if let responder = view.currentFirstResponder() {
        return responder
      }
    }

    return nil
  }
  
  func _firstViewWithIdentifier(_ identifier: FluidViewIdentifier) -> UIView? {
    
    func __firstViewWithIdentifier(view: UIView) -> UIView? {
      
      for subview in view.subviews {
        if let found = __firstViewWithIdentifier(view: subview) {
          return found
        }
      }
      
      if view._identifiers.contains(identifier) {
        return view
      }
      
      return nil
    }
    
    return __firstViewWithIdentifier(view: self)
  }
    
  /**
   Finds a view from this view and descandants.
   */
  public func findView(by identifier: FluidViewIdentifier) -> UIView? {
      
    return _firstViewWithIdentifier(identifier)
    
  }
  
  /**
   Finds a view from the window this view associated.
   */
  public func findViewFromWindow(by identifier: FluidViewIdentifier) -> UIView? {
        
    let window = sequence(first: superview, next: { $0?.superview }).lazy.compactMap { $0 }.first { $0 is UIWindow }
    
    guard let window = window else {
      Log.error(.default, "\(self) is not in hierarchy")
      return nil
    }
    
    return window._firstViewWithIdentifier(identifier)
    
  }
  
}

public struct FluidViewIdentifier: Hashable {
  
  public var rawIdentifier: String
  
  public init(_ raw: String) {
    self.rawIdentifier = raw
  }

  public func combined(_ raw: String) -> Self {
    return .init("\(rawIdentifier)|\(raw)")
  }
}

