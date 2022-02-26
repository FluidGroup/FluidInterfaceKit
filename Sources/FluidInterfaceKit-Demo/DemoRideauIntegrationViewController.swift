//
//  DemoRideauIntegrationViewController.swift
//  FluidInterfaceKit-Demo
//
//  Created by Muukii on 2022/01/23.
//

import CompositionKit
import FluidInterfaceKit
import FluidInterfaceKitRideauSupport
import Foundation
import MondrianLayout
import ResultBuilderKit
import StorybookKit
import UIKit

final class DemoRideauIntegrationViewController: FluidStackController {

  init() {
    super.init(configuration: .init(retainsRootViewController: false))
    definesPresentationContext = true
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground

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

        Self.makeCell(
          title: "Present as Fluid",
          onTap: { [unowned self] in

            _display()
          }
        )
        
        Self.makeCell(
          title: "Present as modal",
          onTap: { [unowned self] in

            _display_present()
          }
        )
      }
    )

  }

  private func _display() {

    let body = ContentViewController { instance in
      instance.fluidPop(transition: nil, completion: nil)
    }

    let rideauController = FluidRideauViewController(
      bodyViewController: body,
      configuration: .init(
        snapPoints: [.pointsFromTop(200)],
        topMarginOption: .fromSafeArea(0)
      ),
      initialSnapPoint: .pointsFromTop(200),
      resizingOption: .noResize
    )

    addContentViewController(rideauController, transition: nil)

  }
  
  private func _display_present() {

    let body = ContentViewController { instance in
      instance.dismiss(animated: true, completion: nil)
    }

    let rideauController = FluidRideauViewController(
      bodyViewController: body,
      configuration: .init(
        snapPoints: [.pointsFromTop(200)],
        topMarginOption: .fromSafeArea(0)
      ),
      initialSnapPoint: .pointsFromTop(200),
      resizingOption: .noResize
    )

    present(rideauController, animated: true)

  }

  private static func makeCell(title: String, onTap: @escaping () -> Void) -> UIView {
    let button = UIButton(type: .system)
    button.setTitle(title, for: .normal)
    button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
    button.onTap {
      onTap()
    }

    return AnyView { _ in
      VStackBlock {
        button
      }
      .padding(10)
    }
  }

}

private final class ContentViewController: FluidStackController {

  private let _dismiss: (ContentViewController) -> Void

  init(
    dismiss: @escaping (ContentViewController) -> Void
  ) {
    self._dismiss = dismiss
    super.init()
  }

  required init?(
    coder: NSCoder
  ) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .neonRandom()

    Mondrian.buildSubviews(on: view) {
      ZStackBlock {
        VStackBlock {
          UIButton(type: .system)&>.do {
            $0.setTitle("Dismiss", for: .normal)
            $0.onTap { [unowned self] in
              _dismiss(self)
            }
          }
          
          UIButton(type: .system)&>.do {
            $0.setTitle("FluidPush", for: .normal)
            $0.onTap { [unowned self] in
              let controller = FluidViewController()
              controller.view.backgroundColor = .neon(.yellow)
              fluidPush(controller, target: .current, relation: .hierarchicalNavigation)
            }
          }
        }
      }
    }

  }

}
