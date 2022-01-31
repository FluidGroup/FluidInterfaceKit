
import UIKit

public final class AnyMirrorViewProvider {
      
  public struct Handlers {
    public var make: ((_ cached: UIView?) -> UIView)?
  }
  
  private let handlers: Handlers
  
  private var cached: UIView?
  
  public init(_ maker: (inout Handlers) -> Void) {
    var handlers = Handlers()
    maker(&handlers)
    self.handlers = handlers
  }
  
  func view() -> UIView {
    assert(Thread.isMainThread)
    let created = handlers.make!(cached)
    cached = created
    return created
  }
  
  public func make() -> AnyMirrorViewProvider {
    assert(Thread.isMainThread)
    let created = handlers.make!(cached)
    cached = created
    return self
  }
}

extension AnyMirrorViewProvider {
  
  public static func portal(view: UIView) -> Self {
    return .init { handlers in
      handlers.make = { cached in
        if let cached = cached {
          return cached
        }
        let newView = PortalView(sourceView: view)
        newView.isUserInteractionEnabled = false
        return newView
      }
    }
  }
  
  public static func portal(layer: CALayer) -> Self {
    return .init { handlers in
      handlers.make = { cached in
        if let cached = cached {
          return cached
        }
        let newView = PortalView(sourceLayer: layer)
        newView.isUserInteractionEnabled = false
        return newView
      }
    }
  }
  
  public static func snapshot(caches: Bool, viewProvider: @escaping () -> UIView) -> Self {
    
    return .init { handlers in
      
      handlers.make = { cached in
        if caches, let cached = cached {
          return cached
        }
        return viewProvider().snapshotView(afterScreenUpdates: false) ?? UIView()
      }
      
    }
  }
  
  public static func actual(viewProvider: @escaping () -> UIView) -> Self {
    
    return .init { handlers in
      
      handlers.make = { cached in
        if let cached = cached {
          return cached
        }
        return viewProvider()
      }
      
    }
  }
  
}
