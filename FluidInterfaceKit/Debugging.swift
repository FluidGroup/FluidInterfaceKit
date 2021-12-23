//
//  Debugging.swift
//  FluidInterfaceKit
//
//  Created by Muukii on 2021/12/23.
//

import Foundation
import UIKit

extension TimeInterval {



}

extension CALayer {

  func dumpAllAnimations() {

    let animations = (animationKeys() ?? []).compactMap {
      animation(forKey: $0)
    }

    let result = animations.map {
      "- \($0.debugDescription)"
    }
    .joined(separator: "\n")

    print(result)

  }
}
