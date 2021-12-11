//
//  DemoViewController.swift
//  FluidUIKit-Demo
//
//  Created by Muukii on 2021/12/12.
//

import Foundation
import MondrianLayout
import FluidUIKit
import UIKit
import StorybookKit

final class DemoViewController: ZStackContainerViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white

    let startButton = UIButton(type: .system)
    startButton.setTitle("Start", for: .normal)
    startButton.addTarget(self, action: #selector(onTapStartButton), for: .primaryActionTriggered)


    view.mondrian.buildSubviews {
      LayoutContainer(attachedSafeAreaEdges: .all) {
        ZStackBlock {

          startButton

        }
      }
    }
  }

  @objc private func onTapStartButton() {
    addContentViewController(ContentViewController(color: BookGenerator.randomColor()))
  }

}

final class ContentViewController: UIViewController {

  init(color: UIColor) {
    super.init(nibName: nil, bundle: nil)
    view.backgroundColor = color
  }

  required init?(coder aDecoder: NSCoder) {
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

    let dismissButton = UIButton(type: .system)
    dismissButton.setTitle("Dimiss", for: .normal)
    dismissButton.addTarget(self, action: #selector(onTapDismissButton), for: .primaryActionTriggered)

    let addButton = UIButton(type: .system)
    addButton.setTitle("Add", for: .normal)
    addButton.addTarget(self, action: #selector(onTapStartButton), for: .primaryActionTriggered)

    view.mondrian.buildSubviews {
      LayoutContainer(attachedSafeAreaEdges: .all) {
        ZStackBlock {
          VStackBlock {

            addButton

            dismissButton
          }
        }
      }
    }

  }

  @objc private func onTapStartButton() {
    zStackViewControllerContext?.addContentViewController(ContentViewController(color: BookGenerator.randomColor()))
  }

  @objc private func onTapDismissButton() {
    zStackViewControllerContext?.removeSelf()
  }
}
