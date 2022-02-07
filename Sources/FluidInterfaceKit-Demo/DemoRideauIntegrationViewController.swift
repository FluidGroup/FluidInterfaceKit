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
    super.init()
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
          title: "Present",
          onTap: { [unowned self] in

            _display()
          }
        )
      }
    )

  }

  private func _display() {

    let body = PlaceholderViewController { instance in
      instance.dismissFluid(transition: nil, completion: nil)
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

private final class PlaceholderViewController: UIViewController {

  private let _dismiss: (PlaceholderViewController) -> Void

  init(
    dismiss: @escaping (PlaceholderViewController) -> Void
  ) {
    self._dismiss = dismiss
    super.init(nibName: nil, bundle: nil)
  }

  required init?(
    coder: NSCoder
  ) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .neonRandom()

    let dismissButton = UIButton(type: .system)&>.do {
      $0.setTitle("Dismiss", for: .normal)
      $0.onTap { [unowned self] in
        _dismiss(self)
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
