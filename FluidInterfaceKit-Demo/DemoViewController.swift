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

    definesPresentationContext = true

    view.backgroundColor = .systemBackground

    let addButton = UIButton(type: .system)&>.do {
      $0.setTitle("Add", for: .normal)
      $0.onTap { [unowned self] in
        addContentViewController(
          ContentViewController(color: BookGenerator.randomColor()),
          transition: .popup()
        )
      }
    }

    let alertButton = UIButton(type: .system)&>.do {
      $0.setTitle("Show UIAlertController", for: .normal)
      $0.onTap { [unowned self] in
        let alert = UIAlertController(title: "Hi", message: nil, preferredStyle: .alert)
        alert.addAction(.init(title: "Close", style: .default, handler: { _ in

        }))
        present(alert, animated: true, completion: nil)
      }
    }

    Mondrian.buildSubviews(on: contentView) {
      LayoutContainer(attachedSafeAreaEdges: .all) {
        ZStackBlock {

          VStackBlock {

            UILabel()&>.do {
              $0.text = "Here is FluidStackViewController"
              $0.textColor = .label
            }

            addButton

            alertButton
          }

        }
      }
    }
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
      $0.setTitle("Remove self", for: .normal)
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
      $0.setTitle("Add Interactive content", for: .normal)
      $0.onTap { [unowned self] in

        fluidStackViewControllerContext?.addContentViewController(
          FluidViewController(
            bodyViewController: ContentViewController(color: BookGenerator.randomColor()),
            transition: .noTransition,
            interactionToRemove: .horizontalDragging(backwardingMode: nil, hidingViews: [])
          ),
          transition: nil
        )
      }
    }

    let alertButton = UIButton(type: .system)&>.do {
      $0.setTitle("Show UIAlertController", for: .normal)
      $0.onTap { [unowned self] in
        let alert = UIAlertController(title: "Hi", message: nil, preferredStyle: .alert)
        alert.addAction(.init(title: "Close", style: .default, handler: { _ in

        }))
        present(alert, animated: true, completion: nil)
      }
    }

    let removeAllButton = UIButton(type: .system)&>.do {
      $0.setTitle("Remove all", for: .normal)
      $0.onTap { [unowned self] in
        fluidStackViewControllerContext
      }
    }

    Mondrian.buildSubviews(on: view) {
      LayoutContainer(attachedSafeAreaEdges: .all) {
        ZStackBlock {
          VStackBlock {

            addButton

            addInteractiveButton

            alertButton

            removeAllButton
            
            dismissButton

          }
        }
      }
    }

  }

}
