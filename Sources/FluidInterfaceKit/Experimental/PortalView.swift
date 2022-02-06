import UIKit

/// https://developer.limneos.net/index.php?ios=12.1&framework=QuartzCore.framework&header=CAPortalLayer.h
public final class PortalView: UIView {
  
  private struct State: Equatable {
    var isEnabled: Bool = true
    var isInHierarchy: Bool = false
    weak var sourceLayer: CALayer?
  }
  
  private var state: State = .init() {
    didSet {
      guard state != oldValue else { return }
      update(with: state)
    }
  }

  public override class var layerClass: AnyClass {
    NSClassFromString(encodeText("DBQpsubmMbzfs", -1))!
  }
  
  public var sourceLayer: CALayer? {
    get {
      state.sourceLayer
    }
    set {
      state.sourceLayer = newValue
    }
  }

  /// Default: false
  public var hidesSourceLayer: Bool {
    get { layer.value(forKey: "hidesSourceLayer") as? Bool ?? false }
    set { layer.setValue(newValue, forKey: "hidesSourceLayer") }
  }
  
  /// Default: false
  public var matchesOpacity: Bool {
    get { layer.value(forKey: "matchesOpacity") as? Bool ?? false }
    set { layer.setValue(newValue, forKey: "matchesOpacity") }
  }
  
  public var matchesPosition: Bool {
    get { layer.value(forKey: "matchesPosition") as? Bool ?? false }
    set { layer.setValue(newValue, forKey: "matchesPosition") }
  }
  
  public var isEnabled: Bool {
    get {
      state.isEnabled
    }
    set {
      state.isEnabled = newValue
    }
  }
  
  public override func action(for layer: CALayer, forKey event: String) -> CAAction? {
    
    switch event {
    case "onOrderIn":
      state.isInHierarchy = true
    case "onOrderOut":
      state.isInHierarchy = false
    default:
      break
    }
    
    return super.action(for: layer, forKey: event)
  }
    
  public override init(frame: CGRect) {
    super.init(frame: frame)
    isUserInteractionEnabled = false
  }
  
  public convenience init(sourceView: UIView) {
    self.init(frame: sourceView.bounds)
    self.sourceLayer = sourceView.layer
    update(with: state)
  }
  
  public convenience init(sourceLayer: CALayer) {
    self.init(frame: sourceLayer.bounds)
    self.sourceLayer = sourceLayer
    update(with: state)
  }
  
  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
   
  private func update(with state: State) {
    
    assert(Thread.isMainThread)
    if state.isEnabled && state.isInHierarchy {
      Log.debug(.portal, "Enabled mirroring")
      layer.setValue(state.sourceLayer, forKey: "sourceLayer")
    } else {
      Log.debug(.portal, "Disabled mirroring")
      layer.setValue(nil, forKey: "sourceLayer")
    }
    
  }
}

private func encodeText(_ string: String, _ key: Int) -> String {
  var result = ""
  for c in string.unicodeScalars {
    result.append(Character(UnicodeScalar(UInt32(Int(c.value) + key))!))
  }
  return result
}
