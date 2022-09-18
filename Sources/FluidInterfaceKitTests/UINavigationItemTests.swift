//
//  UINavigationItemTests.swift
//  FluidInterfaceKitTests
//
//  Created by Muukii on 2022/02/11.
//

import Foundation
import XCTest

@MainActor
final class UINavigationItemTests: XCTestCase {
  
  func testBarButtonItems() {
    
    let item = UINavigationItem()
    
    item.rightBarButtonItem = .init(customView: .init())
    
    XCTAssertEqual(item.rightBarButtonItems?.count, 1)
    
  }
}
