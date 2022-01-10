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

  public let contentView: UIView

  public private(set) var isInvalidated: Bool = false

  private var callbacks: [(Event) -> Void] = []

  init(contentView: UIView) {
    self.contentView = contentView
  }

  func invalidate() {
    isInvalidated = true

    callbacks.forEach { $0(.interrupted) }
  }

  public func addEventHandler(_ closure: @escaping (Event) -> Void) {
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
