
/**
 A transition for removing in ``FluidStackViewController`` or ``TransitionViewController``
 */
public struct AnyBatchRemovingTransition {

  private let _startTransition: (BatchRemovingTransitionContext) -> Void

  public init(
    startTransition: @escaping (BatchRemovingTransitionContext) -> Void
  ) {
    self._startTransition = startTransition
  }

  public func startTransition(context: BatchRemovingTransitionContext) {
    _startTransition(context)
  }
}
