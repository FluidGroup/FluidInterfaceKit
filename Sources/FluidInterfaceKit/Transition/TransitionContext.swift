import UIKit

public class TransitionContext: Equatable {

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

  public internal(set) var isInvalidated: Bool = false
  
  init(contentView: UIView) {
    self.contentView = contentView
  }

  func invalidate() {
    fatalError("Override method")
  }
  
  /// Returns a ``CGRect`` for a given view related to ``contentView``.
  public func frameInContentView(for view: UIView) -> CGRect {
    view._matchedTransition_relativeFrame(
      in: contentView,
      ignoresTransform: true
    )
  }

}
