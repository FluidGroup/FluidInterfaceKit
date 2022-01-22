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

  /**
   Returns the view controller's nearest ancestor ``FluidStackController`` (including itself) with a given identifier.
   
   ``FluidStackController`` can set an identifier on init.
   */
  public func fluidStackController(with identifier: FluidStackController.Identifier) -> FluidStackController? {

    let found = sequence(first: self) {
      $0.parent
    }
    .first(where: { controller in

      guard let controller = controller as? FluidStackController else {
        return false
      }

      guard controller.identifier == identifier else {
        return false
      }

      return true
    })
    
    return found as? FluidStackController
  }

}
