import CompositionKit
import FluidInterfaceKit
import MondrianLayout
import UIKit
import ResultBuilderKit

final class DemoApplicationController: FluidSwitchController {

  override func viewDidLoad() {
    super.viewDidLoad()

    setViewController(AppTabBarController())
  }

}

final class AppTabBarController: UITabBarController {

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white

    viewControllers = [
      UINavigationController(rootViewController: AppSearchViewController()),
      UINavigationController(rootViewController: AppOtherController()),
    ]

    tabBar.backgroundColor = .black
  }

}

final class AppSearchViewController: FluidStackController {

  init() {
    super.init()
    title = "Search"
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .neon(.cyan)

    let list = VGridView(numberOfColumns: 1)

    Mondrian.buildSubviews(on: view) {
      ZStackBlock(alignment: .attach(.all)) {
        list
          .viewBlock
      }
      .container(respectingSafeAreaEdges: .all)
    }

    list.setContents(
      buildArray {

        makeButtonView(
          title: "Open",
          onTap: { [unowned self] in

            let controller = AppOptionsController()

            addContentViewController(controller, transition: .modalIdiom())

          }
        )

      }
    )

  }

}

final class AppOptionsController: CodeBasedViewController, ViewControllerFluidContentType {

  override init() {
    super.init()
    title = "Options"
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .neon(.red)

    let list = VGridView(numberOfColumns: 1)

    Mondrian.buildSubviews(on: view) {
      ZStackBlock(alignment: .attach(.all)) {
        list
          .viewBlock
      }
      .container(respectingSafeAreaEdges: .all)
    }

    list.setContents(
      buildArray {

        makeButtonView(
          title: "Dismiss",
          onTap: { [unowned self] in

            fluidStackControllerContext?.removeSelf(transition: nil)

          }
        )

        makeButtonView(
          title: "Open",
          onTap: { [unowned self] in

            let controller = AppOptionsController()

            fluidStackControllerContext?.addContentViewController(controller, transition: nil)

          }
        )

      }
    )
  }
}


final class AppOtherController: CodeBasedViewController {

  override init() {
    super.init()
    title = "Other"
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .neon(.blue)
  }
}
