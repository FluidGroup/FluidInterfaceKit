
import UIKit

@MainActor
private var ref: Void?

extension UINavigationItem {
  
  /**
   For FluidInterfaceKit property
   A Boolean value indicates whether the navigation item can display the navigation bar in ``FluidViewController``.
   
   KVO compatible
   */
  @objc(fluidIsEnabled)
  public var fluidIsEnabled: Bool {
    get {
      (objc_getAssociatedObject(self, &ref) as? Bool) ?? true
    }
    set {
      willChangeValue(forKey: #keyPath(fluidIsEnabled))
      if fluidIsEnabled != newValue {
        objc_setAssociatedObject(self, &ref, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        didChangeValue(forKey: #keyPath(fluidIsEnabled))
      }
    }
  }
  
}
