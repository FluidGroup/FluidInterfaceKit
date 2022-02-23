//
//  DemoViewController.swift
//  FluidUIKit-Demo
//
//  Created by Muukii on 2021/12/12.
//

import FluidInterfaceKit
import FluidInterfaceKitRideauSupport
import Foundation
import MondrianLayout
import StorybookKit
import UIKit

final class DemoStackingViewController: FluidStackController {

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

        fluidPush(
          ContentViewController(color: .neonRandom())
            .fluidWrapped(configuration: .defaultModal),
          target: .current,
          relation: nil
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
      LayoutContainer(attachedSafeAreaEdges: .all) {
        ZStackBlock {
          VStackBlock(alignment: .leading) {

            UIButton.make(title: "Add in current", color: .white) { [unowned self] in
              fluidPush(
                ContentViewController(color: .neonRandom())
                  .fluidWrapped(
                    configuration: .defaultNavigation
                  ),
                target: .current,
                relation: .hierarchicalNavigation
              )
            }
            
            UIButton.make(title: "Add popover in current", color: .white) { [unowned self] in
                                                                                                             
              fluidPush(
                FluidPopoverViewController(
                  content: .viewController(ContentViewController(color: .neonRandom())),
                  background: .view(UIVisualEffectView(effect: UIBlurEffect(style: .dark)))
                ),
                target: .current
              )
            }

            UIButton.make(title: "Add sheet (Rideau)", color: .white) { [unowned self] in

              let controller = FluidRideauViewController(
                bodyViewController: ContentViewController(color: .neonRandom()),
                configuration: .init(
                  snapPoints: [.pointsFromTop(200)],
                  topMarginOption: .fromSafeArea(0)
                ),
                initialSnapPoint: .pointsFromTop(200),
                resizingOption: .resizeToVisibleArea
              )

              fluidPush(
                controller,
                target: .current
              )
            }

            UIButton.make(title: "Add as modal", color: .white) { [unowned self] in
              present(ContentViewController(color: .neonRandom()), animated: true, completion: nil)
            }

            UIButton.make(title: "Add Navigated", color: .white) { [unowned self] in

              let content = ContentViewController(color: .neonRandom())
              content.title = "Navigated"

              fluidPush(
                content.fluidWrapped(configuration: .init(transition: .navigationStyle, topBar: .navigation)),
                target: .current,
                relation: .modality,
                transition: nil
              )

            }

            UIButton.make(title: "Add Interactive content", color: .white) { [unowned self] in

              fluidPush(
                FluidViewController(
                  content: .init(bodyViewController: ContentViewController(color: .neonRandom())),
                  configuration: .init(
                    transition: .init(
                      addingTransition: nil,
                      removingTransition: nil,
                      removingInteraction: .horizontalDragging(
                        backwardingMode: nil,
                        hidingViews: []
                      )
                    ),
                    topBar: .navigation
                  )

                ),
                target: .current,
                relation: .hierarchicalNavigation,
                transition: nil
              )

            }

            UIButton.make(title: "Show UIAlertController", color: .white) { [unowned self] in
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

            UIButton.make(title: "Add new stack", color: .white) { [unowned self] in

              let padding = FluidViewController()
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
                relation: .modality,
                transition: .modalStyle
              )
            }

            UIButton.make(title: "Remove all", color: .white) { [unowned self] in

              fluidStackContext?.removeAllViewController(transition: .springFlourish())

            }

            UIButton.make(title: "Remove self - overriding transition", color: .white) { [unowned self] in
              fluidPop(transition: .vanishing, completion: nil)
            }
            
            UIButton.make(title: "Remove self", color: .white) { [unowned self] in
              fluidPop()
            }

            UIButton.make(title: "Set title", color: .white) { [unowned self] in
              self.title = "Fluid!"
            }

            UIButton.make(title: "Toggle fluidIsEnabled", color: .white) { [unowned self] in
              self.navigationItem.fluidIsEnabled.toggle()
            }

          }
        }
        .padding(.horizontal, 24)
      }
    }

  }

}
