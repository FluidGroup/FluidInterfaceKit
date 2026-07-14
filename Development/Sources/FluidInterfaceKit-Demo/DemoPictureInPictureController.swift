//
//  DemoPictureInPictureController.swift
//  FluidInterfaceKit-Demo
//
//  Created by Muukii on 2022/01/13.
//

import CompositionKit
import FluidStack
import FluidPictureInPicture
import Foundation
import MondrianLayout
import UIKit

final class DemoPictureInPictureController: FluidPictureInPictureController {

  init() {
    super.init(content: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground

    let label = UILabel()&>.do {
      $0.text = "PiP"
    }

    let backgroundView = UIView()
    backgroundView.backgroundColor = .systemOrange

    let content = AnyUIView { _ in
      ZStackBlock {
        VStackBlock {
          label
        }
      }
      .background(backgroundView)
    }

    let interactiveView = InteractiveView(
      animation: .bodyShrink,
      haptics: .impactOnTouchUpInside(),
      useLongPressGesture: false,
      contentView: content
    )

    interactiveView.handlers.onTap = { [unowned self] in
      setMode(.hiding)
    }

    setContent(interactiveView)

    Mondrian.buildSubviews(on: view) {
      ZStackBlock {
        VStackBlock {
          UIButton.make(title: "hiding") { [unowned self] in
            setMode(.hiding)
          }

          UIButton.make(title: "floating") { [unowned self] in
            setMode(.floating)
          }

          UIButton.make(title: "Add safeArea") { [unowned self] in
            additionalSafeAreaInsets.bottom += 20
          }
        }
      }
    }
  }
}
