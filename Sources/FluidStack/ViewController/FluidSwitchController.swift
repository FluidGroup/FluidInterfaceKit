import UIKit

/**
 A container view controller that switches a view controller to display.
 It's similar with ``UITabBarController``, but no selection UI.
 */
open class FluidSwitchController: UIViewController {

  public private(set) var currentDisplayViewController: UIViewController? {
    didSet {
      setNeedsStatusBarAppearanceUpdate()
    }
  }

  open override var childForStatusBarStyle: UIViewController? {
    return currentDisplayViewController
  }

  open override var childForStatusBarHidden: UIViewController? {
    return currentDisplayViewController
  }

  public func setViewController(_ viewController: UIViewController) {

    if let currentDisplayViewController = currentDisplayViewController {
      currentDisplayViewController.willMove(toParent: nil)
      currentDisplayViewController.view.removeFromSuperview()
      currentDisplayViewController.removeFromParent()
    }

    addChild(viewController)
    view.addSubview(viewController.view)
    viewController.view.frame = view.bounds
    viewController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    viewController.didMove(toParent: self)
    currentDisplayViewController = viewController
  }

  public init() {
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  open override func viewDidLoad() {
    super.viewDidLoad()

    view.accessibilityIdentifier = "Fluid.Switch"
  }
}
