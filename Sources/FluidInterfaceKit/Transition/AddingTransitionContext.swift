import UIKit

/**
 A context object to interact with container view controller for transitions.
 */
public final class AddingTransitionContext: TransitionContext {

  public static func == (
    lhs: AddingTransitionContext,
    rhs: AddingTransitionContext
  ) -> Bool {
    lhs === rhs
  }

  public private(set) var isCompleted: Bool = false
  public let fromViewController: UIViewController?

  /// A view controller to display
  /// No needs to add to content view, it's been done.
  public let toViewController: UIViewController
  private let onCompleted: (AddingTransitionContext) -> Void

  init(
    contentView: UIView,
    fromViewController: UIViewController?,
    toViewController: UIViewController,
    onCompleted: @escaping (AddingTransitionContext) -> Void
  ) {
    self.fromViewController = fromViewController
    self.toViewController = toViewController
    self.onCompleted = onCompleted
    super.init(contentView: contentView)
  }

  /**
   Tells the container view controller what the animation has completed.
   */
  public func notifyCompleted() {
    isCompleted = true
    onCompleted(self)
  }

}
