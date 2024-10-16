import UIKit
import GeometryKit
import ResultBuilderKit

/**
 A transition for removing in ``FluidStackController`` or ``TransitionViewController``
 */
public struct AnyRemovingTransition {

  public let name: String
  private let _startTransition: @MainActor (RemovingTransitionContext) -> Void

  public init(
    name: String = "\(#file),\(#line)",
    startTransition: sending @escaping @MainActor (RemovingTransitionContext) -> Void
  ) {
    self.name = name
    self._startTransition = startTransition
  }

  @MainActor
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
    backup: sending Self,
    startTransition: sending @escaping @MainActor (RemovingTransitionContext) throws -> Void    
  ) -> Self {
    
    return .init(name: name) { context in

      do {
        try startTransition(context)
      } catch {
        backup.startTransition(context: context)
      }

    }
  }
  
  /**
   A wrapper that provides a concrete transition on demand.
   */
  public static func `dynamic`(
    name: String = "dynamic \(#file),\(#line)",
    transition: sending @escaping @MainActor () -> Self
  ) -> Self {
    return .init(name: name) { context in
      let _transition = transition()
      _transition.startTransition(context: context)
    }
  }

}
