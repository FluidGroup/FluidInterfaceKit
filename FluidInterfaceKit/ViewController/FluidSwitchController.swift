import UIKit

open class FluidSwitchController: UIViewController {

  public private(set) var currentDisplayViewController: UIViewController?

  public func setViewController(_ viewController: UIViewController) {

    if let currentDisplayViewController = currentDisplayViewController {
      currentDisplayViewController.willMove(toParent: nil)
      currentDisplayViewController.view.removeFromSuperview()
      currentDisplayViewController.removeFromParent()
    }

    addChild(viewController)
    view.addSubview(viewController.view)
    viewController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    viewController.didMove(toParent: self)
    currentDisplayViewController = viewController
  }

}
