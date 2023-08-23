import Foundation
import CoreGraphics

public struct KeyboardFrameInfo: Equatable, Sendable {
  public var height: CGFloat

  init(height: CGFloat) {
    self.height = height
  }
}
