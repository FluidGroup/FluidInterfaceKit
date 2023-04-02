import UIKit

public final class FluidPopoverHostingView<Content: UIView>: UIView {

  private lazy var reparentingView = _ReparentingView()

  public init(content: Content) {
    self.content = content
    super.init(frame: .zero)
    addSubview(content)
    content.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      content.topAnchor.constraint(equalTo: topAnchor),
      content.bottomAnchor.constraint(equalTo: bottomAnchor),
      content.leadingAnchor.constraint(equalTo: leadingAnchor),
      content.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public let content: Content

  @discardableResult
  public func showReparentingView() -> UIView {
    if reparentingView.superview == nil {
      addSubview(reparentingView)
    }
    return reparentingView
  }
}

fileprivate final class _ReparentingView: UIView {

  private var widthConstraint: NSLayoutConstraint!

  init() {
    super.init(frame: .null)


  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override var center: CGPoint {
    didSet {
      updateFrame()
    }
  }

  override var bounds: CGRect {
    didSet {
      updateFrame()
    }
  }

  override func didMoveToWindow() {
    super.didMoveToWindow()
    updateFrame()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    updateFrame()
  }

  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

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
      origin: .init(x: -position.origin.x, y: 0),
      size: .init(width: window.bounds.size.width, height: 30)
    )

    if self.frame != frame {
      self.frame = frame
    }
  }

}

