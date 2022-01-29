import class UIKit.UIViewController

extension UIViewController {

  /**
   Returns all ``FluidStackController``s in hierachy of the ``UIWindow``.
   */
  public func fluidStackControllers() -> ReversedCollection<[FluidStackController]> {

    return sequence(first: self) {
      $0.parent
    }
    .compactMap { $0 as? FluidStackController }
    .reversed()

  }

  /**
   Returns root ``FluidStackController`` in hierachy of the ``UIWindow``.
   */
  public func rootFluidStackController() -> FluidStackController? {
    fluidStackControllers().first
  }
  
  public struct FluidStackFindStrategy {
    
    let whereClosure: (FluidStackController) -> Bool
    
    public init(_ where: @escaping (FluidStackController) -> Bool) {
      self.whereClosure = `where`
    }

    /// Finds by identifier
    public static func identifier(_ identifier: FluidStackController.Identifier) -> Self {
      .init { stackController in
        stackController.identifier == identifier
      }
    }
    
    /// Finds by composed strategy
    public static func matching(
      _ strategies: [FluidStackFindStrategy]
    ) -> Self {
      return .init { stackController in
        for strategy in strategies {
          if strategy.whereClosure(stackController) {
            return true
          }
        }
        return false
      }
    }
    
  }

  /**
   Returns the view controller's nearest ancestor ``FluidStackController`` (including itself) with a given strategy
   
   ``FluidStackController`` can set an identifier on init.
   */
  public func fluidStackController(with strategy: FluidStackFindStrategy) -> FluidStackController? {

    let found = sequence(first: self) {
      $0.parent
    }
    .first(where: { controller in

      guard let controller = controller as? FluidStackController else {
        return false
      }
      
      return strategy.whereClosure(controller)
    })
    
    return found as? FluidStackController
  }

}
