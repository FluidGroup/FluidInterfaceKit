import UIKit

public class TransitionContext: Equatable {

  public enum Event {
    case finished
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

  private var callbacks: [(Event) -> Void] = []

  init(contentView: UIView) {
    self.contentView = contentView
  }

  func invalidate() {
    assert(Thread.isMainThread)
    isInvalidated = true
    callbacks.forEach { $0(.interrupted) }
  }

  public func addEventHandler(_ closure: @escaping (Event) -> Void) {
    assert(Thread.isMainThread)
    callbacks.append(closure)
  }

  /**
   Triggers `callbacks`.
   */
  func transitionFinished() {
    callbacks.forEach{ $0(.finished) }
  }

  public func frameInContentView(for view: UIView) -> CGRect {
    view._matchedTransition_relativeFrame(
      in: contentView,
      ignoresTransform: true
    )
  }

}
