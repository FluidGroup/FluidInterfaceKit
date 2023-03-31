
import UIKit
import FluidRuntime

/// https://github.com/LeoNatan/Apple-Runtime-Headers/blob/master/iOS/PrivateFrameworks/UIKitCore.framework/_UIPortalView.h
public final class NativePortalView: UIView {

  private let backingView: UIView

  public init(sourceView: UIView) {

    let targetClass = NSClassFromString("_" + encodeText("VJQpsubmWjfx", -1)) as! UIView.Type

    let instance = makeFromClass(targetClass)!

    self.backingView = instance

    super.init(frame: .null)

    addSubview(backingView)

    self.sourceView = sourceView

  }

  @available(*, unavailable)
  public required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  public override func layoutSubviews() {
    super.layoutSubviews()

    backingView.frame = bounds
  }

  /// Default: false
  public var sourceView: UIView? {
    get { backingView.value(forKey: "sourceView") as? UIView }
    set { backingView.setValue(newValue, forKey: "sourceView") }
  }

  /// Default: false
  public var hidesSourceView: Bool {
    get { backingView.value(forKey: "hidesSourceView") as? Bool ?? false }
    set { backingView.setValue(newValue, forKey: "hidesSourceView") }
  }

  /// Default: false
  public var matchesOpacity: Bool {
    get { backingView.value(forKey: "matchesOpacity") as? Bool ?? false }
    set { backingView.setValue(newValue, forKey: "matchesOpacity") }
  }

  public var matchesPosition: Bool {
    get { backingView.value(forKey: "matchesPosition") as? Bool ?? false }
    set { backingView.setValue(newValue, forKey: "matchesPosition") }
  }

  public var matchesTransform: Bool {
    get { backingView.value(forKey: "matchesTransform") as? Bool ?? false }
    set { backingView.setValue(newValue, forKey: "matchesTransform") }
  }

  /// Default: false
  public var allowsHitTesting: Bool {
    get { backingView.value(forKey: "allowsHitTesting") as? Bool ?? false }
    set { backingView.setValue(newValue, forKey: "allowsHitTesting") }
  }

  public var forwardsClientHitTestingToSourceView: Bool {
    get { backingView.value(forKey: "forwardsClientHitTestingToSourceView") as? Bool ?? false }
    set { backingView.setValue(newValue, forKey: "forwardsClientHitTestingToSourceView") }
  }

  public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    let view = super.hitTest(point, with: event)

    if view == self {
      return nil
    }

    return view
  }
}

