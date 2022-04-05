import UIKit

public protocol FluidExtentionViewController: UIViewController {}

extension UIViewController: FluidExtentionViewController {}

extension FluidExtentionViewController {
    
  // MARK: - Push
  
  /**
   Adds a given view controller to the target ``FluidStackController``.
   
   - Parameters:
   - target: Specify how to find a target to display
   - transition: You may set ``AnyAddingTransition/noAnimation`` to disable animation, nil runs transition given view controller provides (if it's ``FluidTransitionViewController``).
   */
  public func fluidPushUnsafely(
    _ viewController: UIViewController,
    target strategy: UIViewController.FluidStackFindStrategy,
    transition: AnyAddingTransition? = nil,
    completion: ((AddingTransitionContext.CompletionEvent) -> Void)? = nil
  ) {
    
    subscribeParent()
        
    guard self.parent != nil else {
      
      let message = "Presenting \(viewController) would fail, The presenter \(self) is not in view controller hierarchy (not having parent)."
      Log.error(.viewController, message)
      
      // TODO: There is a risk of getting reference cycles for `self` in completion closure.
      self._pendingPushOperations.append(
        (
          viewController: viewController,
          strategy: strategy,
          transition: transition,
          completion: completion
        )
      )
      
      return
    }
    
    guard let stackController = fluidStackController(with: strategy) else {
      
      let message =
      "Could not present \(viewController) because not found target stack: \(strategy). Found tree: \(sequence(first: self, next: \.parent).map { $0 }). This view controller \(self) might be presented as modal-presentation."
      
      Log.error(.viewController, message)
      assertionFailure(
        message
      )
      return
    }
    
    stackController
      .addContentViewController(
        viewController,
        transition: transition,
        completion: completion
      )
    
  }
  
  /**
   Adds a given view controller to the target ``FluidStackController``.
   
   - Parameters:
   - target: Specify how to find a target to display
   - transition: You may set ``AnyAddingTransition/noAnimation`` to disable animation, nil runs transition given view controller provides (if it's ``FluidTransitionViewController``).
   */
  public func fluidPush(
    _ viewController: FluidViewController,
    target strategy: UIViewController.FluidStackFindStrategy,
    relation: StackingRelation?,
    transition: AnyAddingTransition? = nil,
    completion: ((AddingTransitionContext.CompletionEvent) -> Void)? = nil
  ) {
    
    /// to trigger `viewDidLoad` before calling `willTransition`.
    viewController.loadViewIfNeeded()
    
    viewController.willTransition(with: relation)
    
    fluidPushUnsafely(
      viewController,
      target: strategy,
      transition: transition
    )
    
  }
  
  public func fluidPush(
    _ viewController: FluidPopoverViewController,
    target strategy: UIViewController.FluidStackFindStrategy,
    transition: AnyAddingTransition? = nil,
    completion: ((AddingTransitionContext.CompletionEvent) -> Void)? = nil
  ) {
    
    fluidPushUnsafely(
      viewController,
      target: strategy,
      transition: transition
    )
    
  }
  
  // MARK: - Pop
  
  /**
   Removes this view controller (receiver) from the target ``FluidStackController``.
   
   - Parameters:
   - transition: You may set ``AnyRemovingTransition/noAnimation`` to disable animation, nil runs transition given view controller provides (if it's ``FluidTransitionViewController``).
   - fowardingToParent: Forwards to parent to pop if current stack do not have view controller to pop. No effects if the current stack prevents it by ``FluidStackController/Configuration-swift.struct/preventsFowardingPop``
   
   - Warning: To run this method to ``FluidStackController`` does not mean to pop the current top view controller.
   A way to pop the top view controller:
   ```
   stackController.topViewController?.fluidPop()
   ```
   */
  public func fluidPop(
    transition: AnyRemovingTransition? = nil,
    transitionForBatch: AnyBatchRemovingTransition? = .crossDissolve,
    forwardingToParent: Bool = true,
    completion: ((RemovingTransitionContext.CompletionEvent) -> Void)? = nil
  ) {
     
    guard
      let fluidStackContext = fluidStackContext,
      let _ = fluidStackContext.fluidStackController
    else {
      let message = "\(self) is not presented as fluid-presentation"
      Log.error(.viewController, message)
      return
    }
    
    _fluidPop(
      transition: transition,
      transitionForBatch: transitionForBatch,
      forwardingToParent: forwardingToParent,
      completion: completion
    )
    
  }
  
  private func _fluidPop(
    transition: AnyRemovingTransition?,
    transitionForBatch: AnyBatchRemovingTransition?,
    forwardingToParent: Bool,
    completion: ((RemovingTransitionContext.CompletionEvent) -> Void)? = nil
  ) {
        
    guard      
      let fluidStackContext = fluidStackContext,
      let stack = fluidStackContext.fluidStackController
    else {
      return
    }
    
    if
      stack.stackConfiguration.preventsFowardingPop == false,
      forwardingToParent == true,
      stack.stackConfiguration.retainsRootViewController,
      stack.stackingViewControllers.first.map({ self.isDescendant(of: $0) }) == true
    {
      
      // there is no view controller to remove in current stack.
      // forwards to the parent attempt to pop itself in the stack
      
      stack._fluidPop(
        transition: transition,
        transitionForBatch: transitionForBatch,
        forwardingToParent: forwardingToParent,
        completion: completion
      )
      
    } else {
      
      fluidStackContext
        .removeSelf(
          transition: transition,
          transitionForBatch: transitionForBatch,
          completion: completion
        )
      
    }
    
  }
  
  /**
   Whether this view controller or its parent recursively is in ``FluidStackController``.
   */
  public var isInFluidStackController: Bool {
    fluidStackContext != nil
  }

  // MARK: - Wrapping
  
  /**
   Creates ``FluidViewController`` with itself.
   
   You may use this method in ``UIViewController/fluidPush``.
   
   ```swift
   let controller: YourViewController
   
   fluidPush(controller.fluidWrapped(...), ...)
   ```
   */
  @_disfavoredOverload
  public func fluidWrapped(
    configuration: FluidViewController.Configuration
  ) -> FluidViewController {
    
    if let self = self as? FluidViewController {
      Log.error(.viewController, "Attempt to wrap with FluidViewController \(self), but it's been wrapped already.")
      return self
    }
    
    return .init(
      content: .init(bodyViewController: self, view: nil),
      configuration: configuration
    )
  }
}

