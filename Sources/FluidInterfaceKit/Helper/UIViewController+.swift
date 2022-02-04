import class UIKit.UIViewController
import ObjectiveC

extension UIViewController {

  /**
   Returns all ``FluidStackController``s in hierachy of the ``UIWindow``.
   */
  public func fluidStackControllers() -> [FluidStackController] {

    return sequence(first: self) {
      $0.next
    }
    .compactMap { $0 as? FluidStackController }
    
  }

  public struct FluidStackFindStrategy {
  
    let pick: ([FluidStackController]) -> FluidStackController?
        
    /// Creates an instance
    /// - Parameter where: Solves find by return true. Given instances come from the nearest one.
    public init(_ pick: @escaping ([FluidStackController]) -> FluidStackController?) {
      self.pick = pick
    }

    /// Finds by identifier
    public static func identifier(_ identifier: FluidStackController.Identifier) -> Self {
      .init { stackControllers in
        stackControllers.first { $0.identifier == identifier }
      }
    }
    
    /**
     Finds a nearest ``FluidStackController``.
     */
    public static let current: Self = {
      .init { controllers in
        controllers.first
      }
    }()
    
    /**
     Finds a root ``FluidStackController`` in the UIWindow.
     */
    public static let root: Self = {
      .init { controllers in
        controllers.last
      }
    }()
    
    /// Finds by composed strategy
    public static func matching(
      _ strategies: [FluidStackFindStrategy]
    ) -> Self {
      return .init { stackControllers in
        for strategy in strategies {
          if let found = strategy.pick(stackControllers) {
            return found
          }
        }
        return nil
      }
    }
    
  }

  /**
   Returns the view controller's nearest ancestor ``FluidStackController`` (including itself) with a given strategy
   
   ``FluidStackController`` can set an identifier on init.
   */
  public func fluidStackController(with strategy: FluidStackFindStrategy) -> FluidStackController? {
    
    let controllersOrderByNearest = fluidStackControllers()
    
    return strategy.pick(controllersOrderByNearest)

  }

}

private var fluidStackContextRef: Void?
private var fluidActionHandlerRef: Void?
private var fluidStackContentConfigurationRef: Void?

extension UIViewController {

  /// A struct that configures how to display in ``FluidStackController``
  public var fluidStackContentConfiguration: FluidStackContentConfiguration {
    get {
      (objc_getAssociatedObject(self, &fluidStackContentConfigurationRef)
        as? FluidStackContentConfiguration) ?? .init()
    }
    set {
      objc_setAssociatedObject(
        self,
        &fluidStackContentConfigurationRef,
        newValue,
        .OBJC_ASSOCIATION_COPY_NONATOMIC
      )
    }
  }

  /// A closure that ``FluidStackController`` invokes when raised activities.
  public var fluidStackActionHandler: ((FluidStackAction) -> Void)? {
    get {
      objc_getAssociatedObject(self, &fluidActionHandlerRef) as? (FluidStackAction) -> Void
    }
    set {
      objc_setAssociatedObject(
        self,
        &fluidActionHandlerRef,
        newValue,
        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
      )
    }
  }

  /// [Get]: Returns a stored instance or nearest parent's one.
  /// [Set]: Stores given instance.
  public internal(set) var fluidStackContext: FluidStackContext? {
    get {

      guard let object = objc_getAssociatedObject(self, &fluidStackContextRef) as? FluidStackContext
      else {
        if parent is FluidStackController {
          // stop find
          return nil
        }
        // continue to find from parent
        return parent?.fluidStackContext
      }
      return object

    }
    set {

      objc_setAssociatedObject(
        self,
        &fluidStackContextRef,
        newValue,
        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
      )

      if let newValue = newValue {
        fluidStackActionHandler?(.didSetContext(newValue))
      }
    }

  }
}
