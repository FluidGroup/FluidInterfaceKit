
import UIKit

public final class AnyMirrorViewProvider {
      
  public struct Handlers {
    public var make: ((_ cached: UIView?) -> UIView)?
  }
  
  private let handlers: Handlers
  
  private var cached: UIView?
  
  public init(_ maker: (inout Handlers) -> Void) {
    var handlers = Handlers()
    maker(&handlers)
    self.handlers = handlers
  }
  
  func view() -> UIView {
    assert(Thread.isMainThread)
    let created = handlers.make!(cached)
    cached = created
    return created
  }
  
  public func make() -> AnyMirrorViewProvider {
    assert(Thread.isMainThread)
    let created = handlers.make!(cached)
    cached = created
    return self
  }
}

extension AnyMirrorViewProvider {
  
  public static func portal(view: UIView, hidesSourceOnUsing: Bool = true) -> Self {
    return .init { handlers in
      handlers.make = { cached in
        if let cached = cached {
          return cached
        }
        let newView = PortalView(sourceView: view)
        newView.hidesSourceLayer = hidesSourceOnUsing
        newView.isUserInteractionEnabled = false
        return StretchView(contentView: newView)
      }
    }
  }
  
  public static func portal(layer: CALayer) -> Self {
    return .init { handlers in
      handlers.make = { cached in
        if let cached = cached {
          return cached
        }
        let newView = PortalView(sourceLayer: layer)
        newView.isUserInteractionEnabled = false
        return StretchView(contentView: newView)
      }
    }
  }
  
  public static func snapshot(caches: Bool, viewProvider: @escaping () -> UIView) -> Self {
    
    return .init { handlers in
      
      handlers.make = { cached in
        if caches, let cached = cached {
          return cached
        }
        return viewProvider().snapshotView(afterScreenUpdates: false) ?? UIView()
      }
      
    }
  }
  
  public static func actual(viewProvider: @escaping () -> UIView) -> Self {
    
    return .init { handlers in
      
      handlers.make = { cached in
        if let cached = cached {
          return cached
        }
        return viewProvider()
      }
      
    }
  }
  
}

private final class StretchView: UIView {
  
  let contentView: UIView
  
  var originalSize: CGSize {
    didSet {
      setNeedsDisplay()
    }
  }
  
  private var observation: NSKeyValueObservation?
  
  override var bounds: CGRect {
    didSet {
      setNeedsLayout()
      layoutIfNeeded()
    }
  }
  
  override var frame: CGRect {
    didSet {
      setNeedsLayout()
      layoutIfNeeded()
    }
  }
  
  init(contentView: UIView) {
    self.contentView = contentView
    self.originalSize = contentView.bounds.size
    super.init(frame: .init(origin: .zero, size: originalSize))
    
    clipsToBounds = true
    
    addSubview(contentView)
    
    observation = contentView.observe(\.bounds) { [weak self] contentView, _ in
      guard let self = self else { return }
      self.invalidateIntrinsicContentSize()
      self.originalSize = contentView.bounds.size
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    observation?.invalidate()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    guard
      bounds.size.width > 0,
      bounds.size.height > 0,
      originalSize.width > 0,
      originalSize.height > 0
    else {
      return
    }
    
    let transform = CGAffineTransform(
      scaleX: bounds.size.width / originalSize.width,
      y: bounds.size.height / originalSize.height
    )
    
    contentView.transform = transform
    contentView.frame.origin = .zero
  }
  
  override var intrinsicContentSize: CGSize {
    contentView.bounds.size
  }
  
  override func sizeThatFits(_ size: CGSize) -> CGSize {
    contentView.sizeThatFits(size)
  }
  
}
