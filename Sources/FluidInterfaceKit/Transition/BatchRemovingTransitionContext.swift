import UIKit

/// A context object to interact with container view controller for transitions.
public final class BatchRemovingTransitionContext: TransitionContext {

  final class ChildContext: TransitionContext {
    let targetViewController: UIViewController

    init(
      targetViewController: UIViewController,
      contentView: UIView
    ) {
      self.targetViewController = targetViewController
      super.init(contentView: contentView)
    }
  }

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
  private var childContexts: [ChildContext] = []

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
    assert(Thread.isMainThread)
    isCompleted = true
    onCompleted(self)
  }

  func isInvalidated(for viewController: UIViewController) -> Bool {
    assert(Thread.isMainThread)
    guard let context = childContexts.first(where: { $0.targetViewController == viewController })
    else {
      assertionFailure("target child context was not created")
      return false
    }
    return context.isInvalidated
  }

  func child(for viewControllerToRemove: UIViewController) -> ChildContext {
    assert(Thread.isMainThread)
    precondition(fromViewControllers.contains(viewControllerToRemove))
    if let created = childContexts.first(where: {
      $0.targetViewController == viewControllerToRemove
    }) {
      return created
    }

    let new = ChildContext(targetViewController: viewControllerToRemove, contentView: contentView)
    childContexts.append(new)

    return new
  }
}
