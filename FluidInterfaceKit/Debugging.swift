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

    let result = animations.map { animation -> String in

      switch animation {
      case let basicAnimation as CABasicAnimation:

        let values = [
          basicAnimation.fromValue.map {
            "from: \($0)"
          },
          basicAnimation.byValue.map {
            "by: \($0)"
          },
          basicAnimation.toValue.map {
            "to: \($0)"
          },
        ]
          .compactMap { $0 }
          .joined(separator: ", ")

        return "- [Basic] keyPath: \(basicAnimation.keyPath ?? "null"), \(values), isAdditive: \(basicAnimation.isAdditive)"
      case let springAnimation as CASpringAnimation:

        let values = [
          springAnimation.fromValue.map {
            "from: \($0)"
          },
          springAnimation.byValue.map {
            "by: \($0)"
          },
          springAnimation.toValue.map {
            "to: \($0)"
          },
        ]
          .compactMap { $0 }
          .joined(separator: ", ")

        return "- [Spring] keyPath: \(springAnimation.keyPath ?? "null"), \(values), isAdditive: \(springAnimation.isAdditive)"
      case let propertyAnimation as CAPropertyAnimation:
        return "- [Property] keyPath: \(propertyAnimation.keyPath ?? "null")"
      default:
        return "- \(animation.debugDescription)"
      }

    }
      .map { "  \($0)" }
      .joined(separator: "\n")

    print(
      """
      \(self) has \(animations.count) animations
      \(result)
      """
    )

  }
}
