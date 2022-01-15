import UIKit

extension UIViewController {

  public func fluidStackControllers() -> ReversedCollection<[FluidStackController]> {

    return sequence(first: self) {
      $0.parent
    }
    .compactMap { $0 as? FluidStackController }
    .reversed()

  }

  public func rootFluidStackController() -> FluidStackController? {
    fluidStackControllers().first
  }

}
