import UIKit

/**
 A context object to interact with container view controller for transitions.
 */
public final class RemovingTransitionContext: TransitionContext {

  public private(set) var isCompleted: Bool = false

  public let fromViewController: UIViewController
  public let toViewController: UIViewController?
  
  private let onAnimationCompleted: (RemovingTransitionContext) -> Void

  init(
    contentView: UIView,
    fromViewController: UIViewController,
    toViewController: UIViewController?,
    onAnimationCompleted: @escaping (RemovingTransitionContext) -> Void
  ) {
    self.fromViewController = fromViewController
    self.toViewController = toViewController
    self.onAnimationCompleted = onAnimationCompleted
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

}
