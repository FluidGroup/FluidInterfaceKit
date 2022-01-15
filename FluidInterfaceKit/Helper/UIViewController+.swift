import UIKit

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

}
