import UIKit

/**
 Describes component for contextual-component
 
 Implemented class: ``ContextualTransitionSourceView``
 */
public protocol ContextualTransitionSourceComponentType {
  
  /// Should returns a view that used for disclosing source view.
  var contentView: UIView { get }
  
  /**
   Returns a new instance, consumers are responsible to dispose of it.
   Created the view must be outside of the content view
     
   It should be this shape below.
   - View
     - contentView
     - reparentingView
   */
  func requestReparentView() -> ReparentingView
}

open class ContextualTransitionSourceView: UIView, ContextualTransitionSourceComponentType {
  
  public let contentView: UIView
  
  public init(contentView: UIView) {
    self.contentView = contentView
    super.init(frame: .null)
    setup()
  }
  
  public init() {
    self.contentView = .init()
    super.init(frame: .null)
    setup()
  }
 
  @inline(__always)
  private func setup() {
    addSubview(contentView)
    contentView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      contentView.topAnchor.constraint(equalTo: topAnchor),
      contentView.leftAnchor.constraint(equalTo: leftAnchor),
      contentView.rightAnchor.constraint(equalTo: rightAnchor),
      contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
  }
  
  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  /**
   Returns a new instance, consumers is responsible to dispose it.
   */
  public func requestReparentView() -> ReparentingView {
    let reparentingView = ReparentingView()
    addSubview(reparentingView)
    return reparentingView
  }
  
}
