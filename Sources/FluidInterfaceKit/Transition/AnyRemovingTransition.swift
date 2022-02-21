import UIKit
import GeometryKit
import ResultBuilderKit

/**
 A transition for removing in ``FluidStackController`` or ``TransitionViewController``
 */
public struct AnyRemovingTransition {

  public let name: String
  private let _startTransition: (RemovingTransitionContext) -> Void

  public init(
    name: String = "\(#file),\(#line)",
    startTransition: @escaping (RemovingTransitionContext) -> Void
  ) {
    self.name = name
    self._startTransition = startTransition
  }

  public func startTransition(context: RemovingTransitionContext) {
    _startTransition(context)
  }
}

extension AnyRemovingTransition {

  /**
   Creates an instance that can cancel with error and fall back to the given transition.
   May use this in case of the transition needs to run throwing operations to start animations.
   Specify backup parameter a transition that works safely.
   */
  public static func throwing(
    name: String = "\(#file),\(#line)",
    backup: Self,
    startTransition: @escaping (RemovingTransitionContext) throws -> Void
  ) -> Self {
    
    return .init(name: name) { context in

      do {
        try startTransition(context)
      } catch {
        backup.startTransition(context: context)
      }

    }
  }

}
