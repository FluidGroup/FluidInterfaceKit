
import QuartzCore

extension CALayer {

  func activeLayer() -> CALayer {
    presentation() ?? self
  }

}
