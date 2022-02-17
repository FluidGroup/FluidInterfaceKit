//
//  UINavigationItemTests.swift
//  FluidInterfaceKitTests
//
//  Created by Muukii on 2022/02/11.
//

import FluidInterfaceKit
import Foundation
import XCTest

final class FluidViewControllerTests: XCTestCase {

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

  private func prepare(_ viewController: UIViewController) {
    viewController.loadViewIfNeeded()
    viewController.beginAppearanceTransition(true, animated: true)
    viewController.endAppearanceTransition()
    viewController.view.layoutIfNeeded()
  }

}
