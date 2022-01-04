//
//  DemoViewController.swift
//  FluidUIKit-Demo
//
//  Created by Muukii on 2021/12/12.
//

import FluidInterfaceKit
import Foundation
import MondrianLayout
import StorybookKit
import UIKit

final class DemoViewController: FluidStackViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white

    let startButton = UIButton(type: .system)
    startButton.setTitle("Start", for: .normal)
    startButton.addTarget(self, action: #selector(onTapStartButton), for: .primaryActionTriggered)

    Mondrian.buildSubviews(on: view) {
      LayoutContainer(attachedSafeAreaEdges: .all) {
        ZStackBlock {

          startButton

        }
      }
    }
  }

  @objc private func onTapStartButton() {
    addContentViewController(
      ContentViewController(color: BookGenerator.randomColor()),
      transition: nil
    )
  }

}

final class ContentViewController: UIViewController, ViewControllerFluidContentType {

  init(
    color: UIColor
  ) {
    super.init(nibName: nil, bundle: nil)
    view.backgroundColor = color
  }

  required init?(
    coder aDecoder: NSCoder
  ) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    print("viewWillAppear: \(self)")
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    print("viewDidAppear: \(self)")
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    print("viewWillDisappear: \(self)")
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    print("viewDidDisappear: \(self)")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let dismissButton = UIButton(type: .system)&>.do {
      $0.setTitle("Dimiss", for: .normal)
      $0.onTap { [unowned self] in
        fluidStackViewControllerContext?.removeSelf(transition: .vanishing())
      }
    }

    let addButton = UIButton(type: .system)&>.do {
      $0.setTitle("Add", for: .normal)
      $0.onTap { [unowned self] in
        fluidStackViewControllerContext?.addContentViewController(
          ContentViewController(color: BookGenerator.randomColor()),
          transition: nil
        )
      }
    }

    let addInteractiveButton = UIButton(type: .system)&>.do {
      $0.setTitle("Add Wrapper", for: .normal)
      $0.onTap { [unowned self] in

        fluidStackViewControllerContext?.addContentViewController(
          FluidViewController(
            bodyViewController: ContentViewController(color: BookGenerator.randomColor()),
            transition: .noTransition,
            interactionToRemove: nil
          ),
          transition: nil
        )
      }
    }

    Mondrian.buildSubviews(on: view) {
      LayoutContainer(attachedSafeAreaEdges: .all) {
        ZStackBlock {
          VStackBlock {

            addButton

            addInteractiveButton

            dismissButton
          }
        }
      }
    }

  }

}
