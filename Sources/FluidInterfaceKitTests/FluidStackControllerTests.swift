import FluidInterfaceKit
import Foundation
import XCTest
@testable import FluidInterfaceKit_Demo

final class FluidStackControllerTests: XCTestCase {
  
  func testStackTree() {
    
    let stack = FluidStackController()
    
    let rep: ViewControllerRep = stack.makeRepresentation()
    
    let result = rep.compare(
      expectation: ViewControllerRep(
        pointer: Unmanaged.passUnretained(stack),
        view: ViewRep(
          pointer: nil,
          subviews: {
            
            ViewRep(
              pointer: nil,
              subviews: {
                
              }
            )
            
          }
        ),
        children: {
          
        }
      )
    )
    
    XCTAssertEqual(result.result, true)
  }

  func testAddingRemovingDefaultBehavior() {

    let stack = FluidStackController()

    XCTAssertEqual(stack.stackingViewControllers.count, 0)

    stack.addContentViewController(UIViewController(), transition: .noAnimation)

    XCTAssertEqual(stack.stackingViewControllers.count, 1)

    stack.addContentViewController(UIViewController(), transition: .noAnimation)

    XCTAssertEqual(stack.stackingViewControllers.count, 2)

    stack.removeLastViewController(transition: .noAnimation)

    XCTAssertEqual(stack.stackingViewControllers.count, 1)

    stack.removeLastViewController(transition: .noAnimation)

    XCTAssertEqual(stack.stackingViewControllers.count, 1)
  }

  func testAddingRemovingIncludingRoot() {

    let stack = FluidStackController(configuration: .init(retainsRootViewController: false))

    XCTAssertEqual(stack.stackingViewControllers.count, 0)

    stack.addContentViewController(UIViewController(), transition: .noAnimation)

    XCTAssertEqual(stack.stackingViewControllers.count, 1)

    stack.addContentViewController(UIViewController(), transition: .noAnimation)

    XCTAssertEqual(stack.stackingViewControllers.count, 2)

    stack.removeLastViewController(transition: .noAnimation)

    XCTAssertEqual(stack.stackingViewControllers.count, 1)

    // won't remove root view controller
    stack.removeLastViewController(transition: .noAnimation)

    XCTAssertEqual(stack.stackingViewControllers.count, 0)
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
 
  /**
   UINavigationController retains root view controller
   */
  func testNavigation() {
    
    let n = UINavigationController()
    
    XCTAssertEqual(n.viewControllers.count, 0)
    
    n.pushViewController(.init(), animated: false)
    n.pushViewController(.init(), animated: false)
    
    XCTAssertEqual(n.viewControllers.count, 2)
           
    n.popViewController(animated: false)
    
    XCTAssertEqual(n.viewControllers.count, 1)
    
    n.popViewController(animated: false)
    
    XCTAssertEqual(n.viewControllers.count, 1)
    
  }

  
  func testRemovingRecursively_1() {
    
    let dispatcher = UIViewController()
    
    let stack = FluidStackController()
    
    _ = VC(stack) {
      VC {
      }
      VC {
        VC(FluidStackController()) {
          VC(dispatcher) {}
        }
      }
    }
    
    XCTAssertEqual(stack.stackingViewControllers.count, 2)
    
    // forwards to parent stack
    dispatcher.fluidPop(transition: .noAnimation)
            
    XCTAssertEqual(stack.stackingViewControllers.count, 1)
  }
  
  func testRemovingRecursively_2() {
    
    let dispatcher = UIViewController()
    
    let stack = FluidStackController()
    
    _ = VC(stack) {
      VC {
        VC(FluidStackController()) {
          VC(dispatcher) {}
        }
      }
    }
    
    XCTAssertEqual(stack.stackingViewControllers.count, 1)
    
    // forwards to parent stack
    dispatcher.fluidPop(transition: .noAnimation)
            
    XCTAssertEqual(stack.stackingViewControllers.count, 1)
  }
  
  func testRemovingRecursively_3() {
    
    let dispatcher = UIViewController()
    
    let stack = FluidStackController()
    
    _ = VC(stack) {
      VC {}
      VC {
        VC(FluidStackController()) {
          VC {}
          VC(dispatcher) {}
        }
      }
    }
    
    XCTAssertEqual(stack.stackingViewControllers.count, 2)
    
    // forwards to parent stack
    dispatcher.fluidPop(transition: .noAnimation)
            
    XCTAssertEqual(stack.stackingViewControllers.count, 2)
  }
  
  func testRemovingRecursively_4() {
    
    let dispatcher1 = UIViewController()
    let dispatcher2 = UIViewController()
    
    let stack1 = FluidStackController()
    let stack2 = FluidStackController()
    let stack3 = FluidStackController(identifier: .init("3"))
    
    _ = VC(stack1) {
      VC {}
      VC {
        VC(stack2) {
          VC {
            VC(stack3) {
              VC(dispatcher2) {}
              VC(dispatcher1) {}
            }
          }
        }
      }
      VC {}
    }
    
    XCTAssertEqual(stack1.stackingViewControllers.count, 3)
    XCTAssertEqual(stack2.stackingViewControllers.count, 1)
    XCTAssertEqual(stack3.stackingViewControllers.count, 2)
    
    dispatcher1.fluidPop(transition: .noAnimation)
    
    XCTAssertEqual(stack3.stackingViewControllers.count, 1)
    
    // forwards to parent stack
    dispatcher2.fluidPop(transition: .noAnimation)
    
    XCTAssertEqual(stack1.stackingViewControllers.count, 2)
          
  }
  
  func testAddingDuplicated() {
    
    let content1 = UIViewController()
    let content2 = UIViewController()
    let stack1 = FluidStackController()
    
    stack1.addContentViewController(content1, transition: .noAnimation)
    stack1.addContentViewController(content1, transition: .noAnimation)
    stack1.addContentViewController(content1, transition: .noAnimation)
        
    XCTAssertEqual(stack1.stackingViewControllers.count, 1)
    
    stack1.addContentViewController(content2, transition: .noAnimation)
    stack1.addContentViewController(content1, transition: .noAnimation)
    
    XCTAssertEqual(stack1.stackingViewControllers.count, 2)
  }
}
