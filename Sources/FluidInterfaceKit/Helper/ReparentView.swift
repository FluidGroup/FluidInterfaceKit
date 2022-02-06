import UIKit

/**
 A view that makes container that fits to the window from the view of tree.
 */
open class ReparentView: UIView {

  open override var center: CGPoint {
    didSet {
      updateFrame()
    }
  }

  open override var bounds: CGRect {
    didSet {
      updateFrame()
    }
  }

  open override func didMoveToWindow() {
    super.didMoveToWindow()
    updateFrame()
  }

  open override func layoutSubviews() {
    super.layoutSubviews()
    updateFrame()
  }

  private func updateFrame() {

    guard let window = window else {
      return
    }
    
    guard let superview = superview else {
      return
    }

    let position = superview.convert(superview.bounds, to: window)

    let frame = CGRect(
      origin: .init(x: -position.origin.x, y: -position.origin.y),
      size: window.bounds.size
    )

    self.frame = frame
  }
}
