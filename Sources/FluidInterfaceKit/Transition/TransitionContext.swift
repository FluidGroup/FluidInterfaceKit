import UIKit

public class TransitionContext: Equatable {

  public enum CompletionEvent {
    /// Transition has been finished (no interruption was in there)
    case succeeded
    /// Transition has been interrupted
    case interrupted
  }

  public static func == (
    lhs: TransitionContext,
    rhs: TransitionContext
  ) -> Bool {
    lhs === rhs
  }

  /// A view that stage for transitioning.
  /// You may work with:
  /// - setting background color for dimming.
  /// - adding snapshot(mirror) view.
  public let contentView: UIView

  public private(set) var isInvalidated: Bool = false

  private var callbacks: [(CompletionEvent) -> Void] = []

  init(contentView: UIView) {
    self.contentView = contentView
  }

  /// Marks as this current transition has been outdated.
  /// Another transition's started by owner.
  /// Triggers ``addCompletionEventHandler(_:)`` with ``TransitionContext/CompletionEvent/interrupted``
  func invalidate() {
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

  /// Returns a ``CGRect`` for a given view related to ``contentView``.
  public func frameInContentView(for view: UIView) -> CGRect {
    view._matchedTransition_relativeFrame(
      in: contentView,
      ignoresTransform: true
    )
  }

}
