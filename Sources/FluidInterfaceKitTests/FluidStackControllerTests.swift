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

  func testRemoving2() {

    let stack = FluidStackController()

    _ = VC(stack) {
      VC {}
      VC {}
      VC {}
      VC {}
      VC {}
    }

    XCTAssertEqual(stack.stackingViewControllers.count, 5)
    
    stack.removeLastViewController(transition: .noAnimation)
    
    XCTAssertEqual(stack.stackingViewControllers.count, 4)
  }

  func testFindContext() {

    let controller = UIViewController()

    _ = VC(FluidStackController()) {
      VC {
        VC {
          VC(controller) {

          }
        }
      }
    }

    XCTAssertNotNil(controller.fluidStackContext)

  }

  func testFindStackByIdentifier() {

    let controller = UIViewController()

    _ = VC(FluidStackController(identifier: .init("1"))) {
      VC {
        VC(FluidStackController(identifier: .init("2"))) {
          VC {
            VC {
              VC {

              }
            }
          }
        }
        VC {
          VC(FluidStackController(identifier: .init("3"))) {
            VC {
              VC {
                VC(controller) {

                }
              }
            }
          }
        }
      }
    }

    XCTAssertNotNil(controller.fluidStackController(with: .identifier(.init("1"))))
    XCTAssertNotNil(controller.fluidStackController(with: .identifier(.init("3"))))
    XCTAssertNil(controller.fluidStackController(with: .identifier(.init("2"))))

  }

}
