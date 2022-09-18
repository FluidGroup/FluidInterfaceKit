//
//  UINavigationItemTests.swift
//  FluidInterfaceKitTests
//
//  Created by Muukii on 2022/02/11.
//

import FluidInterfaceKit
import Foundation
import XCTest

@MainActor
final class FluidViewControllerTests: XCTestCase {
  
  @MainActor
  func checkProtocol() {
    
    class ProhibitedVC: UIViewController, ViewControllerAssertionProhibitedPresentInFluidStack {
      
    }
    
    class VC: UIViewController {
      
    }
    
    let pvc = ProhibitedVC()
    
    _ = pvc.fluidWrapped(configuration: .defaultModal)
   
    let vc = VC()
    
    _ = vc.fluidWrapped(configuration: .defaultModal)
    
    
  }

  func testNavigationItemFromBody_no_bar() {

    let body = UIViewController()
    let controller = FluidViewController(
      content: .init(bodyViewController: body),
      configuration: .defaultNavigation
    )

    prepare(controller)

    XCTAssertNotNil(controller.topBar)
    XCTAssertNotNil(controller.topBar as? UINavigationBar)
    XCTAssertEqual(controller.topBar?.isHidden, true)

  }

  func testNavigationItemFromBody_has_bar() {

    let body = UIViewController()
    body.title = "Hello"
    let controller = FluidViewController(
      content: .init(bodyViewController: body),
      configuration: .defaultNavigation
    )

    prepare(controller)

    XCTContext.runActivity(named: "Displays navigation-bar") { a in

      XCTAssertNotNil(controller.topBar)
      XCTAssertNotNil(controller.topBar as? UINavigationBar)
      XCTAssertEqual(controller.topBar?.isHidden, false)

    }

    XCTContext.runActivity(named: "Request hide the bar") { a in

      controller.isTopBarHidden = true

      XCTAssertNotNil(controller.topBar)
      XCTAssertNotNil(controller.topBar as? UINavigationBar)
      XCTAssertEqual(controller.topBar?.isHidden, true)

    }

  }

  func testNavigationItemFromBody_no_bar_and_set_after() {

    let body = UIViewController()
    let controller = FluidViewController(
      content: .init(bodyViewController: body),
      configuration: .defaultNavigation
    )

    prepare(controller)

    XCTContext.runActivity(named: "No bar") { a in

      XCTAssertNotNil(controller.topBar)
      XCTAssertNotNil(controller.topBar as? UINavigationBar)
      XCTAssertEqual(controller.topBar?.isHidden, true)
    }

    XCTContext.runActivity(named: "Set title and displays the bar") { a in

      body.title = "Hello"

      XCTAssertEqual(controller.topBar?.isHidden, false)
    }
    
    XCTContext.runActivity(named: "Set isTopBarHidden = true, bar will hide") { a in
      
      controller.isTopBarHidden = true

      XCTAssertEqual(controller.topBar?.isHidden, true)
    }

    XCTContext.runActivity(named: "Set isTopBarHidden = false, bar will be back") { a in
      
      controller.isTopBarHidden = false
      
      XCTAssertEqual(controller.topBar?.isHidden, false)
    }
        
    XCTContext.runActivity(named: "Set navigationItem.fluidIsEnabled = false, bar will hide") { a in
      
      body.navigationItem.fluidIsEnabled = false
      
      XCTAssertEqual(controller.topBar?.isHidden, true)
    }
    
  }

  func testNavigationItemFromBody_bar_never_display() {

    let body = UIViewController()
    
    let controller = FluidViewController(
      content: .init(bodyViewController: body),
      configuration: .defaultNavigation
    )

    prepare(controller)

    XCTContext.runActivity(named: "No bar") { a in

      XCTAssertNotNil(controller.topBar)
      XCTAssertNotNil(controller.topBar as? UINavigationBar)
      XCTAssertEqual(controller.topBar?.isHidden, true)
    }

    XCTContext.runActivity(named: "Set title and displays the bar") { a in
      
      controller.isTopBarHidden = true

      body.title = "Hello"

      XCTAssertEqual(controller.topBar?.isHidden, true)
    }

  }
  
  @MainActor
  func testFluidPush() {
    
    let exp = expectation(description: "viewDidLoad")
    exp.assertForOverFulfill = true
    exp.expectedFulfillmentCount = 1
    
    let stack = FluidStackController()
    let controller = FluidViewController()
    
    controller.lifecycleEventHandler = { controller, event in
      switch event {
      case .viewDidLoad:
        
        XCTAssertNotNil(controller.parent)
        XCTAssertEqual(controller.parent, stack)
        
        exp.fulfill()
      case .viewWillAppear:
        break
      case .viewDidAppear:
        break
      case .viewWillDisappear:
        break
      case .viewDidDisappear:
        break
      }
    }
    
    stack.fluidPush(controller, target: .current, relation: nil)
    
    wait(for: [exp], timeout: 1)
    
  }

  func testComapreNavigationContrller() {
    
    let exp = expectation(description: "viewDidLoad")
    exp.assertForOverFulfill = true
    exp.expectedFulfillmentCount = 1
    
    let window = UIWindow()
    window.isHidden = false
    
    let stack = UINavigationController()
    window.rootViewController = stack
    let controller = FluidViewController()
    
    controller.lifecycleEventHandler = { controller, event in
      switch event {
      case .viewDidLoad:
        
        XCTAssertNotNil(controller.parent)
        XCTAssertEqual(controller.parent, stack)
        
        exp.fulfill()
      case .viewWillAppear:
        break
      case .viewDidAppear:
        break
      case .viewWillDisappear:
        break
      case .viewDidDisappear:
        break
      }
    }
    
    stack.pushViewController(controller, animated: true)
    
    wait(for: [exp], timeout: 1)
    
  }
  
  
  private func prepare(_ viewController: UIViewController) {
    viewController.loadViewIfNeeded()
    viewController.beginAppearanceTransition(true, animated: true)
    viewController.endAppearanceTransition()
    viewController.view.layoutIfNeeded()
  }

}
