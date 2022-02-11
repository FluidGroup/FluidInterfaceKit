import FluidInterfaceKit
import Foundation
import XCTest

final class FluidStackControllerTests: XCTestCase {

  func testAddingRemoving() {

    let stack = FluidStackController()

    XCTAssertEqual(stack.stackingViewControllers.count, 0)

    stack.addContentViewController(UIViewController(), transition: .noAnimation)

    XCTAssertEqual(stack.stackingViewControllers.count, 1)

    stack.addContentViewController(UIViewController(), transition: .noAnimation)

    XCTAssertEqual(stack.stackingViewControllers.count, 2)

    stack.removeLastViewController(transition: .noAnimation)

    XCTAssertEqual(stack.stackingViewControllers.count, 1)

    stack.removeLastViewController(transition: .noAnimation)

    XCTAssertEqual(stack.stackingViewControllers.count, 0)
  }

  func testAddingRemovingWithRetainRoot() {

    let stack = FluidStackController(configuration: .init(retainsRootViewController: true))

    XCTAssertEqual(stack.stackingViewControllers.count, 0)

    stack.addContentViewController(UIViewController(), transition: .noAnimation)

    XCTAssertEqual(stack.stackingViewControllers.count, 1)

    stack.addContentViewController(UIViewController(), transition: .noAnimation)

    XCTAssertEqual(stack.stackingViewControllers.count, 2)

    stack.removeLastViewController(transition: .noAnimation)

    XCTAssertEqual(stack.stackingViewControllers.count, 1)

    // won't remove root view controller
    stack.removeLastViewController(transition: .noAnimation)

    XCTAssertEqual(stack.stackingViewControllers.count, 1)
  }

  func testFindContext() {

    let stack = FluidStackController()

    let controller = UIViewController()

    let wrapper = FluidWrapperViewController(
      content: .init(bodyViewController: controller, view: nil)
    )

    stack.addContentViewController(wrapper, transition: .noAnimation)

    XCTAssertNotNil(controller.fluidStackContext)

  }

}
