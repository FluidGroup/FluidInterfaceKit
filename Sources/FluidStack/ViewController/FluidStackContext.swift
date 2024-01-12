import UIKit

/// A context object that communicates with ``FluidStackController``.
/// Associated with the view controller displayed on the stack.
public final class FluidStackContext: Equatable {
  
  public static func == (lhs: FluidStackContext, rhs: FluidStackContext) -> Bool {
    lhs === rhs
  }
  
  public private(set) weak var fluidStackController: FluidStackController?
  public private(set) weak var targetViewController: UIViewController?
  
  init(
    fluidStackController: FluidStackController,
    targetViewController: UIViewController
  ) {
    self.fluidStackController = fluidStackController
    self.targetViewController = targetViewController
  }
  
  /**
   Adds view controller to parent container if it presents.
   */
  public func addContentViewController(
    _ viewController: UIViewController,
    transition: AnyAddingTransition?,
    completion: @escaping (AddingTransitionContext.CompletionEvent) -> Void = { _ in }
  ) {
    fluidStackController?.addContentViewController(
      viewController,
      transition: transition,
      completion: completion
    )
  }
  
  public func addContentView(
    _ view: UIView,
    transition: AnyAddingTransition?,
    completion: @escaping (AddingTransitionContext.CompletionEvent) -> Void = { _ in }
  ) {
    fluidStackController?.addContentView(
      view,
      transition: transition,
      completion: completion
    )
  }
  
  /// Removes the target view controller in ``FluidStackController``.
  /// - Parameter transition: if not nil, it would be used override parameter.
  ///
  /// See detail in ``FluidStackController/removeViewController(_:removingRule:transition:transitionForBatch:completion:)``
  public func removeSelf(
    removingRule: RemovingRule = .cascade,
    transition: AnyRemovingTransition?,
    transitionForBatch: AnyBatchRemovingTransition? = .crossDissolve,
    completion: ((RemovingTransitionContext.CompletionEvent) -> Void)? = nil
  ) {
    guard let targetViewController = targetViewController else {
      return
    }
    fluidStackController?.removeViewController(
      targetViewController,
      removingRule: removingRule,
      transition: transition,
      transitionForBatch: transitionForBatch,
      completion: completion
    )
  }
  
  /**
   Starts transition for removing if parent container presents.
   
   See detail in ``FluidStackController/startRemovingForInteraction(_:)``
   */
  public func startRemovingForInteraction() -> RemovingTransitionContext? {
    guard let targetViewController = targetViewController else {
      return nil
    }
    return fluidStackController?.startRemovingForInteraction(targetViewController)
  }
  
  /**
   See detail in ``FluidStackController/removeAllViewController(transition:)``
   */
  public func removeAllViewController(
    transition: AnyBatchRemovingTransition?
  ) {
    fluidStackController?.removeAllViewController(transition: transition)
  }
  
}

