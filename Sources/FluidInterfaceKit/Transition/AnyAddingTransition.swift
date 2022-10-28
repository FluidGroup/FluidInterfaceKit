import GeometryKit
import ResultBuilderKit
import UIKit

/// A transition for adding in ``FluidStackController`` or ``TransitionViewController``
public struct AnyAddingTransition {

  public let name: String
  private let _startTransition: @MainActor (AddingTransitionContext) -> Void

  public init(
    name: String = "\(#file),\(#line)",
    startTransition: @escaping @MainActor (AddingTransitionContext) -> Void
  ) {
    self.name = name
    self._startTransition = startTransition
  }

  @MainActor
  public func startTransition(context: AddingTransitionContext) {
    _startTransition(context)
  }
}

extension AnyAddingTransition {

  /**
   Creates an instance that can cancel with error and fall back to the given transition.
   May use this in case of the transition needs to run throwing operations to start animations.
   Specify backup parameter a transition that works safely.
   */
  public static func throwing(
    name: String = "\(#file),\(#line)",
    backup: Self,
    startTransition: @escaping @MainActor (AddingTransitionContext) throws -> Void
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
    transition: @escaping @MainActor () -> Self
  ) -> Self {
    return .init(name: name) { context in
      let _transition = transition()
      _transition.startTransition(context: context)
    }
  }

}
