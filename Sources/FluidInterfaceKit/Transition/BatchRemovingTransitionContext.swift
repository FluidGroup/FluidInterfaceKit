import UIKit

/// A context object to interact with container view controller for transitions.
@MainActor
public final class BatchRemovingTransitionContext: TransitionContext {
  
  public enum CompletionEvent {
    /// Transition has been finished (no interruption was in there)
    case succeeded
    /// Transition has been interrupted
    case interrupted
  }

  final class ChildContext: TransitionContext {
    let targetViewController: UIViewController
    
    init(
      targetViewController: UIViewController,
      contentView: FluidStackController.StackingPlatterView
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
  private var callbacks: [(CompletionEvent) -> Void] = []

  init(
    contentView: FluidStackController.StackingPlatterView,
    fromViewControllers: [UIViewController],
    toViewController: UIViewController?,
    onCompleted: @escaping (BatchRemovingTransitionContext) -> Void
  ) {
    self.fromViewControllers = fromViewControllers
    self.toViewController = toViewController
    self.onCompleted = onCompleted
    super.init(contentView: contentView)
  }

  deinit {
    Task { [isInvalidated, isCompleted] in
      assert(
        isInvalidated == true || isCompleted == true,
        "\(self) is deallocated without appropriate operation. Call `notifyAnimationCompleted()` or `notifyCancelled()`"
      )
    }
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
  
  /// Marks as this current transition has been outdated.
  /// Another transition's started by owner.
  /// Triggers ``addCompletionEventHandler(_:)`` with ``TransitionContext/CompletionEvent/interrupted``
  override func invalidate() {
    assert(Thread.isMainThread)
    isInvalidated = true
    callbacks.forEach { $0(.interrupted) }
  }
  
  /**
   Adds closure that handles completion events (``CompletionEvent``)
   */
  public func addCompletionEventHandler(_ closure: @escaping (CompletionEvent) -> Void) {
    assert(Thread.isMainThread)
    callbacks.append(closure)
  }

  /**
   Triggers ``addCompletionEventHandler(_:)`` with ``TransitionContext/CompletionEvent/succeeded``
   */
  func transitionSucceeded() {
    callbacks.forEach{ $0(.succeeded) }
  }
}
