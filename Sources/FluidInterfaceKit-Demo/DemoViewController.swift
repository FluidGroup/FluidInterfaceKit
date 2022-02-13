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

final class DemoViewController: FluidStackController {

  init() {
    super.init()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    definesPresentationContext = true

    view.backgroundColor = .systemBackground

    let addButton = UIButton(type: .system)&>.do {
      $0.setTitle("Add root view controller", for: .normal)
      $0.onTap { [unowned self] in
        addContentViewController(
          ContentViewController(color: .neonRandom()),
          transition: .popup()
        )
      }
    }

    let alertButton = UIButton(type: .system)&>.do {
      $0.setTitle("Show UIAlertController", for: .normal)
      $0.onTap { [unowned self] in
        let alert = UIAlertController(title: "Hi", message: nil, preferredStyle: .alert)
        alert.addAction(
          .init(
            title: "Close",
            style: .default,
            handler: { _ in

            }
          )
        )
        present(alert, animated: true, completion: nil)
      }
    }

    Mondrian.buildSubviews(on: contentView) {
      LayoutContainer(attachedSafeAreaEdges: .all) {
        ZStackBlock {

          VStackBlock {

            UILabel()&>.do {
              $0.text = "Here is FluidStackController, components are in contentView."
              $0.numberOfLines = 0
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

private final class ContentViewController: UIViewController {

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

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
    
    Mondrian.buildSubviews(on: view) {
      LayoutContainer(attachedSafeAreaEdges: .all) { [unowned self] /* trick to disable writing `self` */ in
        ZStackBlock {
          VStackBlock {

            UIButton.make(title: "Add in current", color: .white) {
              fluidPush(
                ContentViewController(color: .neonRandom()),
                target: .current,
                transition: .modalIdiom()
              )
            }

            UIButton.make(title: "Add as modal", color: .white) {
              present(ContentViewController(color: .neonRandom()), animated: true, completion: nil)
            }

            UIButton.make(title: "Add Navigated", color: .white) {
              fluidPush(
                FluidViewController(
                  content: .init(bodyViewController: ContentViewController(color: .neonRandom())),
                  transition: .navigation(),
                  topBar: .navigation()
                ),
                target: .current,
                transition: .modalIdiom()
              )

            }

            UIButton.make(title: "Add Interactive content", color: .white) {

              fluidPush(
                FluidViewController(
                  content: .init(bodyViewController: ContentViewController(color: .neonRandom())),
                  transition: .init(
                    addingTransition: nil,
                    removingTransition: nil,
                    removingInteraction: .horizontalDragging(backwardingMode: nil, hidingViews: [])
                  )
                ),
                target: .current,
                transition: nil
              )

            }

            UIButton.make(title: "Show UIAlertController", color: .white) {
              let alert = UIAlertController(title: "Hi", message: nil, preferredStyle: .alert)
              alert.addAction(
                .init(
                  title: "Close",
                  style: .default,
                  handler: { _ in

                  }
                )
              )
              present(alert, animated: true, completion: nil)

            }

            UIButton.make(title: "Add new stack", color: .white) {

              let padding = UIViewController()
              let content = ContentViewController(color: .neonRandom())
              let stack = FluidStackController(
                identifier: .init("nested"),
                rootViewController: content
              )
              padding.addChild(stack)
              Mondrian.buildSubviews(on: padding.view) {
                stack.view
                  .viewBlock
                  .padding(20)
                  .container(respectingSafeAreaEdges: .all)
              }
              stack.didMove(toParent: padding)

              padding.fluidStackContentConfiguration.contentType = .overlay

              fluidPush(
                padding,
                target: .current,
                transition: .modalIdiom()
              )
            }

            UIButton.make(title: "Remove all", color: .white) {

              fluidStackContext?.removeAllViewController(transition: .vanishing())

            }

            UIButton.make(title: "Remove self", color: .white) {
              fluidPop(transition: .vanishing(), completion: nil)
            }

          }
        }
      }
    }

  }

}
