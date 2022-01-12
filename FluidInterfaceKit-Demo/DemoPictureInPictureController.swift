//
//  DemoPictureInPictureController.swift
//  FluidInterfaceKit-Demo
//
//  Created by Muukii on 2022/01/13.
//

import Foundation

import FluidInterfaceKit
import CompositionKit
import UIKit
import MondrianLayout

final class DemoPictureInPictureController: FluidPictureInPictureController {

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground

    let label = UILabel()&>.do {
      $0.text = "PiP"
    }

    let backgroundView = ShapeLayerView.roundedCorner(radius: 8)
    backgroundView.shapeFillColor = .systemOrange

    let content = CompositionKit.AnyView { _ in
      ZStackBlock {
        VStackBlock {
          label
        }
      }
      .background(backgroundView)
    }

    setContent(content)
  }
}
