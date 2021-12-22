//
//  DemoThreadsMessagesViewController.swift
//  FluidUIKit-Demo
//
//  Created by Muukii on 2021/12/12.
//

import CompositionKit
import FluidInterfaceKit
import Foundation
import MondrianLayout
import StorybookKit
import UIKit

/// Message list
final class DemoThreadsMessagesViewController: ZStackViewController {

  private let scrollableContainerView = ScrollableContainerView()

  override func viewDidLoad() {

    super.viewDidLoad()

    view.backgroundColor = .white
    scrollableContainerView.delaysContentTouches = false

    Mondrian.buildSubviews(on: view) {
      ZStackBlock(alignment: .attach(.all)) {
        scrollableContainerView
      }
    }

    func makeHeader() -> UIView {

      let imageView = StyledEdgeView(
        cornerRadius: .circular,
        cornerRoundingStrategy: .mask,
        content: UIView()&>.do {
          $0.backgroundColor = BookGenerator.randomColor()
        }
      )

      return AnyView { view in

        ZStackBlock {
          HStackBlock {

            imageView
              .viewBlock
              .height(160)

          }
        }
        .padding(.top, 80)

      }

    }

    let header = makeHeader()

    var viewControllerCache: [Int : UIViewController] = [:]

    let content = CompositionKit.AnyView.init { view in

      VStackBlock(alignment: .fill) {
        header

        StackingSpacer(minLength: 64, expands: false)

        VGridBlock(
          columns: [
            .init(.flexible(), spacing: 24),
            .init(.flexible(), spacing: 24),
            .init(.flexible(), spacing: 24),
          ],
          spacing: 24
        ) {
          (0..<10).map { index in
            makeListCell(onTap: { [unowned self] cell in
              print(cell)

              if let cached = viewControllerCache[index] {

                addContentViewController(cached, transition: nil)
                
              } else {
                let controller = InteractiveDismissalTransitionViewController(
                  bodyViewController: DemoThreadsDetailViewController(),
                  transition: .init(adding: .popupContextual(from: cell), removing: nil),
                  interaction: .horizontalDragging(
                    backTo: cell,
                    dismiss: { viewController in
                      viewController.zStackViewControllerContext?.removeSelf(transition: nil)
                    }
                  )
                )

                viewControllerCache[index] = controller

                addContentViewController(controller, transition: nil)

              }


            })
          }
        }
        .padding(.horizontal, 24)
      }
    }

    scrollableContainerView.setContent(content)

  }

}

func makeListCell(onTap: @escaping (UIView) -> Void) -> UIView {

  let nameLabel = UILabel()&>.do {
    $0.text = "Muukii"
    $0.font = UIFont.preferredFont(forTextStyle: .headline)
    $0.textColor = .black
  }

  let statusLabel = UILabel()&>.do {
    $0.text = "Active now"
    $0.font = UIFont.preferredFont(forTextStyle: .caption1)
    $0.textColor = .darkGray
  }

  let imageView = UIView()&>.do {
    $0.backgroundColor = BookGenerator.randomColor()
  }

  let backgroundView = UIView()
  backgroundView.backgroundColor = .init(white: 0, alpha: 0.1)
  if #available(iOS 13.0, *) {
    backgroundView.layer.cornerCurve = .continuous
  } else {
    // Fallback on earlier versions
  }
  backgroundView.layer.cornerRadius = 16

  let body = AnyView { _ in

    VStackBlock {
      StyledEdgeView(cornerRadius: .circular, cornerRoundingStrategy: .mask, content: imageView)

      nameLabel
        .viewBlock
        .spacingBefore(8)

      statusLabel
        .viewBlock
        .spacingBefore(4)
    }

  }

  let cell = InteractiveView(
    animation: .customBodyShrink(shrinkingScale: 0.7),
    haptics: .impactOnTouchUpInside(style: .light),
    contentView: body
  )

  cell.handlers.onTap = { [unowned cell] in
    onTap(cell)
  }

  return cell

}

/// Detail
final class DemoThreadsDetailViewController: ZStackViewController {

  private let scrollableContainerView = ScrollableContainerView()
  private let navigationView = NavigationHostingView()

  override func viewDidLoad() {

    super.viewDidLoad()

    view.backgroundColor = BookGenerator.randomColor()

    let footerView: UIView = {

      let label = UILabel()
      label.text = "Hello"

      let button = UIButton(type: .system)&>.do {
        $0.setTitle("Dismiss", for: .normal)
        $0.onTap { [unowned self] in
          self.zStackViewControllerContext?.removeSelf(transition: .vanishing())
        }
      }

      return AnyView { _ in
        HStackBlock {
          label
            .viewBlock
            .padding(8)

          StackingSpacer(minLength: 0)

          button
        }
      }

    }()

    /// cells
    do {
      func makeCell() -> UIView {

        let label = UILabel()
        label.text = "Message"

        let backgroundView = UIView()
        backgroundView.backgroundColor = .init(white: 0, alpha: 0.1)
        if #available(iOS 13.0, *) {
          backgroundView.layer.cornerCurve = .continuous
        } else {
          // Fallback on earlier versions
        }
        backgroundView.layer.cornerRadius = 16

        let cell = AnyView { _ in
          HStackBlock {

            StackingSpacer(minLength: 0, expands: true)

            HStackBlock {

              label
                .viewBlock
                .padding(24)
            }
            .background(backgroundView)
            .padding(16)
          }
        }

        return cell

      }

      let content = CompositionKit.AnyView.init { view in
        VStackBlock {
          (0..<10).map { _ in
            makeCell()
          }
        }
      }

      scrollableContainerView.setContent(content)
    }

    Mondrian.buildSubviews(on: view) {
      ZStackBlock {
        scrollableContainerView
          .viewBlock
          .alignSelf(.attach(.all))

        footerView
          .viewBlock
          .huggingPriority(.vertical)
          .relative([.bottom, .horizontal], 0)
      }
    }

    let navigationContentView = AnyView { view in

      let backButton = UIButton(type: .system)&>.do {
        $0.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        $0.tintColor = .appBlack
        $0.onTap { [unowned self] in
          self.zStackViewControllerContext?.removeSelf(transition: .vanishing())
        }
      }

      HStackBlock {
        backButton
          .viewBlock
          .spacingBefore(8)

        HStackBlock {

          StyledEdgeView(
            cornerRadius: .circular,
            cornerRoundingStrategy: .mask,
            content: UIView()&>.do { $0.backgroundColor = .lightGray }
          )

          VStackBlock(alignment: .leading) {

            UILabel.mockSingleline(text: "Muukii", textColor: .appBlack)&>.do {
              $0.font = UIFont.preferredFont(forTextStyle: .headline)
            }

            UILabel.mockSingleline(text: "Active now", textColor: .lightGray)&>.do {
              $0.font = UIFont.preferredFont(forTextStyle: .caption1)
            }
          }
          .spacingBefore(4)

        }
        .spacingBefore(4)
        .spacingAfter(4)

        StackingSpacer(minLength: 0)
      }
    }

    navigationView.setContent(navigationContentView)
    navigationView.setup(on: self)
    navigationView.backgroundColor = .white

  }

}
