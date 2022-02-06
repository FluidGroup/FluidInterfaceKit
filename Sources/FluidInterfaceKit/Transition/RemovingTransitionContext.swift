import UIKit

/**
 A context object to interact with container view controller for transitions.
 */
public final class RemovingTransitionContext: TransitionContext {

  public private(set) var isCompleted: Bool = false

  public let fromViewController: UIViewController
  public let toViewController: UIViewController?
  
  private let onAnimationCompleted: (RemovingTransitionContext) -> Void
  private let onRequestedDisplayOnTop: (DisplaySource) -> FluidStackController.DisplayingOnTopSubscription

  init(
    contentView: UIView,
    fromViewController: UIViewController,
    toViewController: UIViewController?,
    onAnimationCompleted: @escaping (RemovingTransitionContext) -> Void,
    onRequestedDisplayOnTop: @escaping (DisplaySource) -> FluidStackController.DisplayingOnTopSubscription
  ) {
    self.fromViewController = fromViewController
    self.toViewController = toViewController
    self.onAnimationCompleted = onAnimationCompleted
    self.onRequestedDisplayOnTop = onRequestedDisplayOnTop
    super.init(contentView: contentView)
  }

  /**
   Notifies controller transition has been completed.
   */
  public func notifyAnimationCompleted() {
    assert(Thread.isMainThread)
    guard isCompleted == false else { return }
    isCompleted = true
    onAnimationCompleted(self)
  }
  
  public func requestDisplayOnTop(_ source: DisplaySource) -> FluidStackController.DisplayingOnTopSubscription {
    onRequestedDisplayOnTop(source)
  }
    
  public func makeReparentView(for view: UIView) -> ReparentView {
    let reparentView = ReparentView()
    view.addSubview(reparentView)
    return reparentView
  }

}
