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
  
  public func setFluidViewIdentifier<Trait>(_ identifier: FluidViewIdentifier<Trait>?) {
    _identifier = identifier?.rawIdentifier
  }
  
  private var _identifier: String? {
    get {
      objc_getAssociatedObject(self, &identifierRef) as? String
    }
    set {
      objc_setAssociatedObject(self, &identifierRef, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
  }
    
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
  
  func _firstViewWithIdentifier(_ identifier: String) -> UIView? {
    
    func __firstViewWithIdentifier(view: UIView) -> UIView? {
      
      for subview in view.subviews {
        if let found = __firstViewWithIdentifier(view: subview) {
          return found
        }
      }
      
      if view._identifier == identifier {
        return view
      }
      
      return nil
    }
    
    return __firstViewWithIdentifier(view: self)
  }
    
  public func findView<Trait>(by identifier: FluidViewIdentifier<Trait>) -> UIView? {
    
    let window = sequence(first: superview, next: { $0?.superview }).lazy.compactMap { $0 }.first { $0 is UIWindow }
        
    guard let window = window else {
      Log.error(.default, "\(self) is not in hierarchy")
      return nil
    }
    
    return window._firstViewWithIdentifier(identifier.rawIdentifier)
    
  }
  
}

public struct FluidViewIdentifier<Trait>: Hashable {
  
  public var rawIdentifier: String
  
  public init(_ raw: String) {
    self.rawIdentifier = "\(String(reflecting: Trait.self))|\(raw)"
  }

  public func combined(_ raw: String) -> Self {
    return .init("\(rawIdentifier)|\(raw)")
  }
}

