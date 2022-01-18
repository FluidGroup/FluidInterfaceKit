//
//  DemoSafeAreaViewController.swift
//  FluidInterfaceKit-Demo
//
//  Created by Muukii on 2022/01/18.
//

import Foundation
import UIKit
import MondrianLayout

final class DemoSafeAreaViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    let container = UIView.mock(backgroundColor: .neon(.blue))

    Mondrian.buildSubviews(on: view) {

      ZStackBlock(alignment: .attach(.all)) {
        container
      }
    }

    Mondrian.layout {
      view.safeAreaLayoutGuide.mondrian.layout.top(.toSuperview.top, 60)
    }

  }

}
