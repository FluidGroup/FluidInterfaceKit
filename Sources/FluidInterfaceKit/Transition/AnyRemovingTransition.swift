import UIKit
import GeometryKit
import ResultBuilderKit

/**
 A transition for removing in ``FluidStackController`` or ``TransitionViewController``
 */
public struct AnyRemovingTransition {

  private let _startTransition: (RemovingTransitionContext) -> Void

  public init(
    startTransition: @escaping (RemovingTransitionContext) -> Void
  ) {
    self._startTransition = startTransition
  }

  public func startTransition(context: RemovingTransitionContext) {
    _startTransition(context)
  }
}

