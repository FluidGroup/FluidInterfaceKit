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

    func parsingValue(_ value: Any?) -> String {

      guard let value = value else { return "null" }

      switch value {
      case let value as NSValue:

        if #available(iOS 13.0, *) {
          if let transform = value.value(of: CATransform3D.self) {
            return "\(renderCATransform3D(transform))"
          } else {
            return "\(value)"
          }
        } else {
          return "\(value)"
        }
      default:
        return "\(value)"
      }
    }

    func parsingDestinationValues(animation: CABasicAnimation) -> String {
      let values = [
        animation.fromValue
          .map(parsingValue)
          .map {
            "from: \n\($0.indented(2))"
          },
        animation.byValue
          .map(parsingValue)
          .map {
            "by: \n\($0.indented(2))"
          },
        animation.toValue
          .map(parsingValue)
          .map {
            "to: \n\($0.indented(2))"
          },
      ]
        .compactMap { $0 }
        .joined(separator: "\n")
        .indented(2)
      return values
    }

    func renderCATransform3D(_ t: CATransform3D) -> String {

      return """
      [\(t.m11), \(t.m12), \(t.m13), \(t.m14)]
      [\(t.m21), \(t.m22), \(t.m23), \(t.m24)]
      [\(t.m31), \(t.m32), \(t.m33), \(t.m34)]
      [\(t.m41), \(t.m42), \(t.m43), \(t.m44)]
      """
    }

    let result = (animationKeys() ?? []).compactMap { key -> String in
      let animation = self.animation(forKey: key)

      switch animation {
      case let springAnimation as CASpringAnimation:
        let values = parsingDestinationValues(animation: springAnimation)
        return """
- [Spring] : \(key)
  keyPath:
    \(springAnimation.keyPath ?? "null")
\(values)
  isAdditive:
    \(springAnimation.isAdditive)
  velocity:
    \(springAnimation.initialVelocity)
"""
      case let basicAnimation as CABasicAnimation:
        let values = parsingDestinationValues(animation: basicAnimation)
        return """
- [Basic] : \(key)
  keyPath:
    \(basicAnimation.keyPath ?? "null")
\(values)
  isAdditive:
    \(basicAnimation.isAdditive)
"""
      case let propertyAnimation as CAPropertyAnimation:
        return "- [Property] keyPath: \(propertyAnimation.keyPath ?? "null")"
      default:
        return "- \(animation.debugDescription)"
      }

    }
      .flatMap {
        $0.split(separator: "\n")
      }
      .map { "  \($0)" }
      .joined(separator: "\n")

    print(
      """
      \(self)
      \(result)
      """
    )

  }
}

extension String {

  fileprivate func indented(_ size: Int) -> String {

    let spaces = Array(repeating: " ", count: size).joined(separator: "")

    return split(separator: "\n")
      .map { spaces + $0 }
      .joined(separator: "\n")

  }

}
