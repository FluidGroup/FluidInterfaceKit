import UIKit

open class FluidTabBarController: FluidSwitchController {

  public let tabBarContainerView = UIView()

  // TODO:
  open override func viewDidLoad() {
    super.viewDidLoad()

    view.accessibilityIdentifier = "Fluid.Tab"
  }
}
