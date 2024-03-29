//
//  DemoThreadsMessagesViewController.swift
//  FluidUIKit-Demo
//
//  Created by Muukii on 2021/12/12.
//

import CompositionKit
import FluidStack
import Foundation
import MondrianLayout
import StorybookKit
import UIKit

/// Message list
final class DemoThreadsMessagesViewController: FluidStackController {

  private let scrollableContainerView = ScrollableContainerView()

  override func viewDidLoad() {

    super.viewDidLoad()

    view.backgroundColor = .systemBackground
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
          $0.backgroundColor = .neonRandom()
        }
      )

      return AnyUIView { view in

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

    var viewControllerCache: [Int: UIViewController] = [:]

    let content = CompositionKit.AnyUIView.init { view in

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
          (0..<10).map { index -> UIView in

            let color = UIColor.neonRandom()

            return makeListCell(
              color: color,
              onTap: { [unowned self] cell in

                if let cached = viewControllerCache[index] {

                  addContentViewController(cached, transition: nil)

                } else {

                  let mirrorViewProvider = AnyMirrorViewProvider.portal(view: cell)

                  let interpolationView = makeListCell(color: color, onTap: { _ in })
                  interpolationView.isUserInteractionEnabled = false

                  let controller = FluidViewController(
                    content: .init(
                      bodyViewController: DemoThreadsDetailViewController(color: color)
                    ),
                    configuration: .init(
                      transition: .init(
                        addingTransition: .contextualInstagramThreads(
                          from: cell,
                          mirrorViewProvider: mirrorViewProvider,
                          hidingViews: [cell]
                        ),
                        removingTransition: nil,
                        removingInteraction: .horizontalDragging(
                          backwarding: {
                            .gettingTogether(to: UnsafeContextualTransitionSourceComponent(view: cell))
                          }
                        )
                      ),
                      topBar: .navigation
                    )
                  )

                  viewControllerCache[index] = controller

                  addContentViewController(controller, transition: nil)

                }

              }
            )
          }
        }
        .padding(.horizontal, 24)
      }
    }

    scrollableContainerView.setContent(content)

  }

}

@MainActor
private func makeListCell(color: UIColor, onTap: @escaping (UIView) -> Void) -> UIView {

  let nameLabel = UILabel()&>.do {
    $0.text = "Muukii"
    $0.font = UIFont.preferredFont(forTextStyle: .headline)
    $0.textColor = .label
  }

  let statusLabel = UILabel()&>.do {
    $0.text = "Active now"
    $0.font = UIFont.preferredFont(forTextStyle: .caption1)
    $0.textColor = .secondaryLabel
  }

  let imageView = UIView()&>.do {
    $0.backgroundColor = color
  }

  let backgroundView = UIView()
  backgroundView.backgroundColor = .init(white: 0, alpha: 0.1)
  if #available(iOS 13.0, *) {
    backgroundView.layer.cornerCurve = .continuous
  } else {
    // Fallback on earlier versions
  }
  backgroundView.layer.cornerRadius = 16

  let body = AnyUIView { _ in

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
final class DemoThreadsDetailViewController: UIViewController {

  private let scrollableContainerView = ScrollableContainerView()
  private let navigationView = NavigationHostingView()

  private let keyColor: UIColor

  init(
    color: UIColor
  ) {
    self.keyColor = color
    super.init(nibName: nil, bundle: nil)
  }

  required init?(
    coder: NSCoder
  ) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {

    super.viewDidLoad()

    view.backgroundColor = .systemBackground

    let footerView: UIView = {

      let label = UILabel()
      label.text = "Hello"

      let button = UIButton(type: .system)&>.do {
        $0.setTitle("Dismiss", for: .normal)
        $0.onTap { [unowned self] in
          self.fluidStackContext?.removeSelf(transition: .vanishing)
        }
      }

      return AnyUIView { _ in
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

        let cell = AnyUIView { _ in
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

      let content = CompositionKit.AnyUIView.init { view in
        VStackBlock {
          (0..<10).map { _ in
            makeCell()
          }
        }
      }

      scrollableContainerView.setContent(content)
    }

    Mondrian.buildSubviews(on: view) {
      LayoutContainer(attachedSafeAreaEdges: .all) {
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
    }

    let navigationContentView = AnyUIView { view in

      let backButton = UIButton(type: .system)&>.do {
        $0.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        $0.tintColor = .appBlack
        $0.onTap { [unowned self] in
          self.fluidStackContext?.removeSelf(transition: .vanishing)
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
            content: UIView()&>.do { $0.backgroundColor = self.keyColor }
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
    navigationView.backgroundColor = .init(white: 0.95, alpha: 1)

  }

}
