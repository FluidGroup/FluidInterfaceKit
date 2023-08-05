import CoreGraphics

extension CGVector {

  mutating func formFinited() {

    if dx.isNaN || dx.isInfinite {
      dx = 0
    }

    if dy.isNaN || dy.isInfinite {
      dy = 0
    }

  }

}
