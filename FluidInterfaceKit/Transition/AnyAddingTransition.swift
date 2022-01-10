import UIKit
import GeometryKit
import ResultBuilderKit

/**
 A transition for adding in ``FluidStackViewController`` or ``TransitionViewController``
 */
public struct AnyAddingTransition {

  private let _startTransition: (AddingTransitionContext) -> Void

  public init(
    startTransition: @escaping (AddingTransitionContext) -> Void
  ) {
    self._startTransition = startTransition
  }

  public func startTransition(context: AddingTransitionContext) {
    _startTransition(context)
  }
}

