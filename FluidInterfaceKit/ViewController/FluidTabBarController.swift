import UIKit

/**
 A container view controller that manages a multiselection interface, where the selection determines which child view controller to display.
 Built on top of ``FluidSwitchController``
 */
open class FluidTabBarController: FluidSwitchController {

  public let tabBarContainerView = UIView()

  // TODO:
  open override func viewDidLoad() {
    super.viewDidLoad()

    view.accessibilityIdentifier = "Fluid.Tab"
  }
}
