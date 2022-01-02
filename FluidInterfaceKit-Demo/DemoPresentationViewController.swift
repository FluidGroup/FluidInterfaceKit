//
//  DemoPresentation.swift
//  FluidInterfaceKit-Demo
//
//  Created by Muukii on 2021/12/22.
//

import Foundation
import UIKit
import MondrianLayout
import StorybookKit
import FluidInterfaceKit

final class DemoPresentationViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white

    let presentButton = UIButton(type: .system)
    presentButton.setTitle("Present", for: .normal)
    presentButton.onTap { [unowned self] in

      let controller = FluidViewController(
        bodyViewController: PlaceholderViewController(),
        transition: .init(adding: .popup(), removing: nil),
        interactionToRemove: .horizontalDragging(
          backwardingMode: nil,
          hidingViews: []
        )
      )

      controller.modalPresentationStyle = .overCurrentContext

      present(controller, animated: false, completion: nil)

    }

    Mondrian.buildSubviews(on: view) {
      ZStackBlock {
        presentButton
      }
    }
  }
}

fileprivate final class PlaceholderViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = BookGenerator.randomColor()

    let dismissButton = UIButton(type: .system)&>.do {
      $0.setTitle("Dismiss", for: .normal)
      $0.onTap { [unowned self] in
        dismiss(animated: false)
      }
    }

    Mondrian.buildSubviews(on: view) {
      ZStackBlock {
        VStackBlock {
          dismissButton
        }
      }
    }

  }

}
