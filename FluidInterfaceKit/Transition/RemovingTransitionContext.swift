import UIKit

/**
 A context object to interact with container view controller for transitions.
 */
public final class RemovingTransitionContext: TransitionContext {

  public static func == (
    lhs: RemovingTransitionContext,
    rhs: RemovingTransitionContext
  ) -> Bool {
    lhs === rhs
  }

  public private(set) var isCompleted: Bool = false

  public let fromViewController: UIViewController
  public let toViewController: UIViewController?
  private let onCompleted: (RemovingTransitionContext) -> Void

  init(
    contentView: UIView,
    fromViewController: UIViewController,
    toViewController: UIViewController?,
    onCompleted: @escaping (RemovingTransitionContext) -> Void
  ) {
    self.fromViewController = fromViewController
    self.toViewController = toViewController
    self.onCompleted = onCompleted
    super.init(contentView: contentView)
  }

  public func notifyCompleted() {
    isCompleted = true
    onCompleted(self)
  }

}
