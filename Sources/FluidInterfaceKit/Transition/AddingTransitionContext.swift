import UIKit

/**
 A context object to interact with container view controller for transitions.
 */
@MainActor
public final class AddingTransitionContext: TransitionContext {
    
  public enum CompletionEvent {
    /// Transition has been finished (no interruption was in there)
    case succeeded
    /// Transition has been interrupted
    case interrupted
  }

  public private(set) var isCompleted: Bool = false
  public let fromViewController: UIViewController?
  /// A view controller to display
  /// No needs to add to content view, it's been done.
  public let toViewController: UIViewController
  
  private let onAnimationCompleted: (AddingTransitionContext) -> Void

  private var callbacks: [(CompletionEvent) -> Void] = []

  init(
    contentView: FluidStackController.StackingPlatterView,
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
   
   Fine to call multiple times, ignored after the first time.
   */
  public func notifyAnimationCompleted() {
    assert(Thread.isMainThread)
    guard isCompleted == false else { return }
    isCompleted = true
    onAnimationCompleted(self)
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
   Makes toViewController disabled in user-interaction until finish transition.
   */
  public func disableUserInteractionUntileFinish() {
    
    func run(viewController: UIViewController) {
      
      // TODO: there is re-entrancy issue in running transitions simultaneously.
      viewController.view.isUserInteractionEnabled = false
      
      addCompletionEventHandler { [weak viewController] _ in
        viewController?.view.isUserInteractionEnabled = true
      }
    }
    
    fromViewController.map {
      run(viewController: $0)
    }
    
    run(viewController: toViewController)
    
  }

  /**
   Triggers ``addCompletionEventHandler(_:)`` with ``TransitionContext/CompletionEvent/succeeded``
   */
  func transitionSucceeded() {
    callbacks.forEach{ $0(.succeeded) }
  }
  
  deinit {
    Task { [isInvalidated, isCompleted] in
      assert(
        isInvalidated == true || isCompleted == true,
        "\(self) is deallocated without appropriate operation. Call `notifyAnimationCompleted()`"
      )
    }
  }
 
}
