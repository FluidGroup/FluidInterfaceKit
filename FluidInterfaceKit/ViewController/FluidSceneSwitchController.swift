import UIKit

public protocol FluidSceneType {
  var viewController: UIViewController { get }
}

open class FluidSceneSwitchController<Scene: FluidSceneType>: FluidSwitchController {

  public private(set) var scene: Scene?

  @available(*, unavailable)
  public override func setViewController(_ viewController: UIViewController) {
    super.setViewController(viewController)
  }

  public func setScene(_ scene: Scene) {
    self.scene = scene
    super.setViewController(scene.viewController)
  }
}
