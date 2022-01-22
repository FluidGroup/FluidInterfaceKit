import UIKit

public protocol FluidSceneType {
  var viewController: UIViewController { get }
}

/**
 Extended from ``FluidSwitchController``.
 
 ```swift
 enum MyScene: FluidSceneType {
   case loggedOut(UIViewController)
   case loggedIn(UIViewController)
 }
 
 let controller = FluidSceneSwitchController<MyScene>()
 
 // displays the view controller
 controller.setScene(.loggedIn(...))
 ```
 */
open class FluidSceneSwitchController<Scene: FluidSceneType>: FluidSwitchController {

  public private(set) var scene: Scene?

  @available(*, unavailable, message: "Instead use `setScene`")
  public override func setViewController(_ viewController: UIViewController) {
    super.setViewController(viewController)
  }

  public func setScene(_ scene: Scene) {
    self.scene = scene
    super.setViewController(scene.viewController)
  }
}
