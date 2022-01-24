import UIKit

/**
 A context object to interact with container view controller for transitions.
 */
public final class AddingTransitionContext: TransitionContext {

  public private(set) var isCompleted: Bool = false
  public let fromViewController: UIViewController?

  /// A view controller to display
  /// No needs to add to content view, it's been done.
  public let toViewController: UIViewController
  
  private let onAnimationCompleted: (AddingTransitionContext) -> Void

  init(
    contentView: UIView,
    fromViewController: UIViewController?,
    toViewController: UIViewController,
    onAnimationCompleted: @escaping (AddingTransitionContext) -> Void
  ) {
    self.fromViewController = fromViewController
    self.toViewController = toViewController
    self.onAnimationCompleted = onAnimationCompleted
    super.init(contentView: contentView)
  }

  /**
   Tells the container view controller what the animation has completed.
   */
  public func notifyAnimationCompleted() {
    assert(Thread.isMainThread)
    guard isCompleted == false else { return }
    isCompleted = true
    onAnimationCompleted(self)
  }

}
