import UIKit

/**
 A context object to interact with container view controller for transitions.
 */
public final class BatchRemovingTransitionContext: TransitionContext {

  public static func == (
    lhs: BatchRemovingTransitionContext,
    rhs: BatchRemovingTransitionContext
  ) -> Bool {
    lhs === rhs
  }

  public private(set) var isCompleted: Bool = false
  public let fromViewControllers: [UIViewController]
  public let toViewController: UIViewController?
  private let onCompleted: (BatchRemovingTransitionContext) -> Void

  init(
    contentView: UIView,
    fromViewControllers: [UIViewController],
    toViewController: UIViewController?,
    onCompleted: @escaping (BatchRemovingTransitionContext) -> Void
  ) {
    self.fromViewControllers = fromViewControllers
    self.toViewController = toViewController
    self.onCompleted = onCompleted
    super.init(contentView: contentView)
  }

  public func notifyCompleted() {
    isCompleted = true
    onCompleted(self)
  }
}
