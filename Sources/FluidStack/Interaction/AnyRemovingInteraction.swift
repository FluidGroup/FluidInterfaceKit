import GeometryKit
import ResultBuilderKit
import UIKit

/**
 A handler for interaction in removing transition.

 This object has multiple handlers for communicate with interaction.
 */
public struct AnyRemovingInteraction {

  public struct Context {
    /// a ``FluidViewController`` that runs ``AnyRemovingInteraction``
    public let viewController: FluidGestureHandlingViewController
    
    public func startRemovingTransition() -> RemovingTransitionContext {
      precondition(viewController.fluidStackContext != nil)
      return viewController.fluidStackContext!.startRemovingForInteraction()!
    }
  }
  
  public enum GestureConditionEvent {
    case shouldBeRequiredToFailBy(otherGestureRecognizer: UIGestureRecognizer, completion: (Bool) -> Void)
    case shouldRecognizeSimultaneouslyWith(otherGestureRecognizer: UIGestureRecognizer, completion: (Bool) -> Void)
  }

  public typealias GestureHandler<Gesture> = @MainActor (Gesture, Context) -> Void
  
  public typealias GestureCondition<Gesture> = @MainActor (Gesture, GestureConditionEvent) -> Void

  public enum Handler {
    case gestureOnLeftEdge(
      condition: GestureCondition<UIScreenEdgePanGestureRecognizer>,
      handler: GestureHandler<UIScreenEdgePanGestureRecognizer>
    )
    case gestureOnScreen(
      condition: GestureCondition<FluidPanGestureRecognizer>,
      handler: GestureHandler<FluidPanGestureRecognizer>
    )
  }

  public let handlers: [Handler]

  /// Creates an instance
  /// - Parameter handlers: Don't add duplicated handlers
  public init(
    handlers: [Handler]
  ) {
    self.handlers = handlers
  }

  /// Creates an instance
  /// - Parameter handlers: Don't add duplicated handlers
  public init(
    handlers: Handler...
  ) {
    self.handlers = handlers
  }

}

extension AnyRemovingInteraction {
  
  public static var disabled: Self {
    return .init(handlers: [])
  }
}
