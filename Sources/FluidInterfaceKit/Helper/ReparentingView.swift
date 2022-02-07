import UIKit

/**
 A view that makes container that fits to the window from the view of tree.
 */
open class ReparentingView: UIView {

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
  
  public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

    let view = super.hitTest(point, with: event)
    if view == self {
      return nil
    } else {
      return view
    }
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

    if self.frame != frame {
      self.frame = frame
    }
  }
  
}
