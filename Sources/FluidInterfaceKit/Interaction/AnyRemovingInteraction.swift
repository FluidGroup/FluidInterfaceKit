import GeometryKit
import MatchedTransition
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

  public typealias GestureHandler<Gesture> = (Gesture, Context) -> Void

  public enum Handler {
    case gestureOnLeftEdge(handler: GestureHandler<UIScreenEdgePanGestureRecognizer>)
    case gestureOnScreen(handler: GestureHandler<_PanGestureRecognizer>)
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

