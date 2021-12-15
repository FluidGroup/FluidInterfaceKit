//
//  DemoThreadsMessagesViewController.swift
//  FluidUIKit-Demo
//
//  Created by Muukii on 2021/12/12.
//

import Foundation
import MondrianLayout
import FluidInterfaceKit
import UIKit
import CompositionKit
import StorybookKit

final class DemoThreadsMessagesViewController: ZStackViewController {

  private let scrollableContainerView = ScrollableContainerView()

  override func viewDidLoad() {

    super.viewDidLoad()

    view.backgroundColor = .white
    scrollableContainerView.delaysContentTouches = false

    view.mondrian.buildSubviews {
      ZStackBlock(alignment: .attach(.all)) {
        scrollableContainerView
      }
    }

    func makeCell(onTap: @escaping (UIView) -> Void) -> UIView {

      let label = UILabel()
      label.text = "Hello"

      let backgroundView = UIView()
      backgroundView.backgroundColor = .init(white: 0, alpha: 0.1)
      if #available(iOS 13.0, *) {
        backgroundView.layer.cornerCurve = .continuous
      } else {
        // Fallback on earlier versions
      }
      backgroundView.layer.cornerRadius = 16

      let body = AnyView { _ in
        HStackBlock {
          label
            .viewBlock
            .padding(24)
        }
        .background(backgroundView)
      }

      let circularView = CircularClippingView(body)

      let cell = InteractiveView(
        animation: .customBodyShrink(shrinkingScale: 0.7),
        haptics: .impactOnTouchUpInside(style: .light),
        contentView: circularView
      )

      cell.handlers.onTap = { [unowned cell] in
        onTap(cell)
      }

      return cell

    }

    let content = CompositionKit.AnyView.init { view in

      VGridBlock(columns: [
        .init(.flexible(), spacing: 24),
        .init(.flexible(), spacing: 24),
      ], spacing: 24) {
        (0..<10).map { _ in
          makeCell(onTap: { [unowned self] cell in
            print(cell)

            let controller = InteractiveDismissalViewController(
              bodyViewController: DemoThreadsDetailViewController(),
              //              interaction: .leftToRight()
              interaction: .horizontalDragging(
                backTo: cell,
                dismiss: { viewController in
                  viewController.zStackViewControllerContext?.removeSelf(transition: nil)
              })
            )

            addContentViewController(controller, transition: .popupContextual(from: cell))

          })
        }
      }
      .padding(.horizontal, 24)
    }

    scrollableContainerView.setContent(content)

  }

}

final class DemoThreadsDetailViewController: ZStackViewController {

  private let scrollableContainerView = ScrollableContainerView()

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

    view.mondrian.buildSubviews {
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

}
