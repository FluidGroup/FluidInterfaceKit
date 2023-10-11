import UIKit
import FluidPortal

public final class FluidTooltipContainerView<ContentView: UIView>: UIView {

  public let contentView: ContentView

  public let hostingView: FluidTooltipHostingView = .init()

  public init(contentView: ContentView) {
    self.contentView = contentView

    super.init(frame: .null)

    addSubview(hostingView)
    addSubview(contentView)
    contentView.translatesAutoresizingMaskIntoConstraints = false
    hostingView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      contentView.topAnchor.constraint(equalTo: topAnchor),
      contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
      contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])

    NSLayoutConstraint.activate([
      hostingView.topAnchor.constraint(equalTo: topAnchor),
      hostingView.bottomAnchor.constraint(equalTo: bottomAnchor),
      hostingView.leadingAnchor.constraint(equalTo: leadingAnchor),
      hostingView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])

  }
  
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public func activate() -> FluidTooltipContentView {
    hostingView.showReparentingView()
  }

  public func deactivate() {
    hostingView.hide()
  }
}

public final class FluidTooltipHostingView: UIView {

  private lazy var reparentingView = FluidTooltipContentView()
  private var usingPortalStackView: PortalStackView?

  public init() {
    super.init(frame: .null)
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func hide() {
    reparentingView.removeFromSuperview()
    usingPortalStackView?.remove(view: reparentingView)
  }

  func showReparentingView() -> FluidTooltipContentView {
    if reparentingView.superview == nil {
      addSubview(reparentingView)
    }
    return reparentingView
  }

  public override func didMoveToWindow() {
    super.didMoveToWindow()
    let portalStackView = targetPortalStackView()
    self.usingPortalStackView = portalStackView
    portalStackView?.register(view: reparentingView)
  }

  private func targetPortalStackView() -> PortalStackView? {

    func find(parent: UIView) -> PortalStackView? {
      for view in parent.subviews {
        if let portal = view as? PortalStackView {
          return portal
        }
      }
      guard let superview = parent.superview else { return nil }
      return find(parent: superview)
    }

    guard let superview = superview else { return nil }

    return find(parent: superview)

  }

}

public final class FluidTooltipContentView: UIView {

  public let topLayoutGuide = UILayoutGuide()
  public let bottomLayoutGuide = UILayoutGuide()

  public let hostLayoutGuide = UILayoutGuide()

  private var hostLayoutGuideX: NSLayoutConstraint! = nil
  private var hostLayoutGuideY: NSLayoutConstraint! = nil

  private var hostLayoutGuideWidth: NSLayoutConstraint! = nil
  private var hostLayoutGuideHeight: NSLayoutConstraint! = nil

  init() {
    super.init(frame: .null)

    hostLayoutGuide.identifier = "host"
    topLayoutGuide.identifier = "top"
    bottomLayoutGuide.identifier = "bottom"

    addLayoutGuide(hostLayoutGuide)
    addLayoutGuide(topLayoutGuide)
    addLayoutGuide(bottomLayoutGuide)

    hostLayoutGuideX = hostLayoutGuide.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0)
    hostLayoutGuideY = hostLayoutGuide.topAnchor.constraint(equalTo: topAnchor, constant: 0)

    hostLayoutGuideWidth = hostLayoutGuide.widthAnchor.constraint(equalToConstant: 0)
    hostLayoutGuideHeight = hostLayoutGuide.heightAnchor.constraint(equalToConstant: 0)

    NSLayoutConstraint.activate([
      hostLayoutGuideX,
      hostLayoutGuideY,
      hostLayoutGuideWidth,
      hostLayoutGuideHeight
    ])

    NSLayoutConstraint.activate([
      topLayoutGuide.topAnchor.constraint(equalTo: topAnchor),
      topLayoutGuide.leadingAnchor.constraint(equalTo: leadingAnchor),
      topLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor),
      topLayoutGuide.bottomAnchor.constraint(equalTo: hostLayoutGuide.topAnchor),
    ])

    NSLayoutConstraint.activate([
      bottomLayoutGuide.topAnchor.constraint(equalTo: hostLayoutGuide.bottomAnchor),
      bottomLayoutGuide.leadingAnchor.constraint(equalTo: leadingAnchor),
      bottomLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor),
      bottomLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])

  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override var center: CGPoint {
    didSet {
      updateFrame()
    }
  }

  public override var bounds: CGRect {
    didSet {
      updateFrame()
    }
  }

  public override func didMoveToWindow() {
    super.didMoveToWindow()
    updateFrame()
  }

  public override func layoutSubviews() {
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

  public func addSubviewOnTop(view: UIView) {

    addSubview(view)

    view.translatesAutoresizingMaskIntoConstraints = false

    let top = view.topAnchor.constraint(greaterThanOrEqualTo: topLayoutGuide.topAnchor)

    let leading = view.leadingAnchor.constraint(greaterThanOrEqualTo: topLayoutGuide.leadingAnchor)

    let trailing = view.trailingAnchor.constraint(lessThanOrEqualTo: topLayoutGuide.trailingAnchor)

    let centerX = view.centerXAnchor.constraint(equalTo: hostLayoutGuide.centerXAnchor)
    centerX.priority = .defaultHigh

    let bottom = view.bottomAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor)

    NSLayoutConstraint.activate([
      top,
      leading,
      trailing,
      bottom,
      centerX,
    ])

  }

  public func addSubviewOnBottom(view: UIView) {

    addSubview(view)

    view.translatesAutoresizingMaskIntoConstraints = false

    let top = view.topAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor)

    let leading = view.leadingAnchor.constraint(greaterThanOrEqualTo: bottomLayoutGuide.leadingAnchor)

    let trailing = view.trailingAnchor.constraint(lessThanOrEqualTo: bottomLayoutGuide.trailingAnchor)

    let centerX = view.centerXAnchor.constraint(equalTo: hostLayoutGuide.centerXAnchor)
    centerX.priority = .defaultHigh

    let bottom = view.bottomAnchor.constraint(lessThanOrEqualTo: bottomLayoutGuide.bottomAnchor)

    NSLayoutConstraint.activate([
      top,
      leading,
      trailing,
      bottom,
      centerX,
    ])

  }

  private func updateFrame() {

    guard let window = window else {
      return
    }

    guard let superview = superview else {
      return
    }

    let host = superview.bounds

    let position = superview.convert(host, to: window)

    let frame = CGRect(
      origin: .init(x: -position.origin.x, y: window.bounds.height / -2),
      size: window.bounds.size
    )

    if self.frame != frame {
      self.frame = frame
    }

    let guideFrame = superview.convert(host, to: self)

    hostLayoutGuideX.constant = guideFrame.origin.x
    hostLayoutGuideY.constant = guideFrame.origin.y

    hostLayoutGuideWidth.constant = guideFrame.size.width
    hostLayoutGuideHeight.constant = guideFrame.size.height


  }

}

