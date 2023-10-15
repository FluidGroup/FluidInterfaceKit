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

final class DemoPictureInPictureCoolController: FluidPictureInPictureController {

  init() {
    super.init(content: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .black

    let backgroundView = UIView()
    backgroundView.backgroundColor = .neon(.violet)

    let content = AnyUIView { _ in
      ZStackBlock {
        VStackBlock {

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

    content.layer.cornerCurve = .continuous
    content.layer.masksToBounds = true
    content.layer.cornerRadius = 8

    interactiveView.handlers.onTap = { [unowned self] in

      switch state.mode {
      case .maximizing:
        setMode(.floating)
      case .folding:
        break
      case .floating:
        setMode(.maximizing)
      case .hiding:
        break
      }

    }

    setContent(interactiveView)

  }
}
