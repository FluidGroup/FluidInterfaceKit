
import UIKit

extension UIBarButtonItem {
  
  /**
   􀯶
   */
  public static func fluidChevronBackward(onTap: @escaping @MainActor () -> Void) -> Self {
    if #available(iOS 13.0, *) {
      let image = UIImage(systemName: "chevron.backward")
      return .init(image: image, style: .plain, target: nil, action: nil).onTap(onTap)
    } else {
      return .init(barButtonSystemItem: .init(rawValue: 101)!, target: nil, action: nil).onTap(onTap)
    }
  }
  
  /**
   􀅾
   */
  public static func fluidMultiply(onTap: @escaping @MainActor () -> Void) -> Self {
    if #available(iOS 13.0, *) {
      let image = UIImage(systemName: "multiply")
      return .init(image: image, style: .plain, target: nil, action: nil).onTap(onTap)
    } else {
      return .init(barButtonSystemItem: .stop, target: nil, action: nil).onTap(onTap)
    }
  }
  
}

private var ref: Void?

extension UIBarButtonItem {
     
  func onTap(_ closure: @escaping @MainActor () -> Void) -> Self {
    
    target = self
    action = #selector(_fluid_onTap)
    _onTapClosure = closure
    
    return self
  }
  
  private var _onTapClosure: (@MainActor () -> Void)? {
    get {
      objc_getAssociatedObject(self, &ref) as? () -> Void
    }
    set {
      objc_setAssociatedObject(self, &ref, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  @objc private func _fluid_onTap() {
    _onTapClosure?()
  }
  
}
