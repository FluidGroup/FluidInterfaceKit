import UIKit

public final class PortalStackView: UIView {

  private var portalViews: [NativePortalView] = []

  public init() {
    super.init(frame: .null)
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError()
  }

  public func register(view: UIView) {

    guard portalViews.contains(where: { $0.sourceView == view }) == false else {
      return
    }

    let newPortalView = NativePortalView(sourceView: view)
    newPortalView.matchesPosition = true
    newPortalView.hidesSourceView = true
    newPortalView.allowsHitTesting = true
    newPortalView.forwardsClientHitTestingToSourceView = true
    portalViews.append(newPortalView)

    update()

  }

  public func remove(view: UIView) {
    portalViews
      .filter { $0.sourceView == view }
      .forEach { view in
        view.removeFromSuperview()
      }
    portalViews
      .removeAll { $0.sourceView == view }
  }

  private func update() {

    for view in portalViews {
      addSubview(view)
    }
    setNeedsLayout()
    layoutIfNeeded()
  }

  public override func layoutSubviews() {
    super.layoutSubviews()

    for view in portalViews {
      view.frame = bounds
    }
  }

  public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

    let view = super.hitTest(point, with: event)    

    if view == self {
       return nil
    }

    return view
  }

}
