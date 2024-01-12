import UIKit

public protocol FluidExtentionViewController: UIViewController {}

extension UIViewController: FluidExtentionViewController {}

@MainActor
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
    afterViewDidLoad: @escaping @MainActor () -> Void = {},
    completion: (@MainActor (AddingTransitionContext.CompletionEvent) -> Void)? = nil
  ) {
    
    let controller = viewController
    
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
        controller,
        transition: transition,
        afterViewDidLoad: afterViewDidLoad,
        completion: completion
      )
    
  }
  
  /**
   Adds a given view controller to the target ``FluidStackController``.
   
   It guarantees a given view controller will get a reference to the parent view controller after this operation immediately.
   
   - Parameters:
   - target: Specify how to find a target to display
   - transition: You may set ``AnyAddingTransition/noAnimation`` to disable animation, nil runs transition given view controller provides (if it's ``FluidTransitionViewController``).
   */
  @discardableResult
  public func fluidPushUnsafely(
    _ viewController: UIViewController,
    target strategy: UIViewController.FluidStackFindStrategy,
    transition: AnyAddingTransition? = nil,
    afterViewDidLoad: @escaping @MainActor () -> Void = {}
  ) async -> AddingTransitionContext.CompletionEvent {
    await withCheckedContinuation { continuation in
      fluidPushUnsafely(
        viewController,
        target: strategy,
        transition: transition,
        afterViewDidLoad: afterViewDidLoad,
        completion: { event in
          continuation.resume(returning: event)
      })
    }
  }
  
  /**
   Adds a given view controller to the target ``FluidStackController``.
   
   It guarantees a given view controller will get a reference to the parent view controller after this operation immediately.
   
   - Parameters:
   - target: Specify how to find a target to display
   - transition: You may set ``AnyAddingTransition/noAnimation`` to disable animation, nil runs transition given view controller provides (if it's ``FluidTransitionViewController``).
   */
  public func fluidPush(
    _ viewController: FluidViewController,
    target strategy: UIViewController.FluidStackFindStrategy,
    relation: StackingRelation?,
    transition: AnyAddingTransition? = nil,
    completion: (@MainActor (AddingTransitionContext.CompletionEvent) -> Void)? = nil
  ) {
    
    let transaction = Fluid.Transaction.current
    
    transaction.removingInteraction.map {
      viewController.removingInteraction = $0
    }
    
    transaction.removingTransition.map {
      viewController.removingTransition = $0
    }
           
    fluidPushUnsafely(
      viewController,
      target: transaction.stackFindStrategy ?? strategy,
      transition: transaction.addingTransition ?? transition,
      afterViewDidLoad: { [weak viewController] in
        viewController?.willTransition(with: transaction.relation ?? relation)
      },
      completion: completion
    )
    
  }
  
  /**
   Adds a given view controller to the target ``FluidStackController``.
   
   It guarantees a given view controller will get a reference to the parent view controller after this operation immediately.
   
   - Parameters:
   - target: Specify how to find a target to display
   - transition: You may set ``AnyAddingTransition/noAnimation`` to disable animation, nil runs transition given view controller provides (if it's ``FluidTransitionViewController``).
   */
  @discardableResult
  public func fluidPush(
    _ viewController: FluidViewController,
    target strategy: UIViewController.FluidStackFindStrategy,
    relation: StackingRelation?,
    transition: AnyAddingTransition? = nil
  ) async -> AddingTransitionContext.CompletionEvent {
    
    await withCheckedContinuation { continuation in
      fluidPush(
        viewController,
        target: strategy,
        relation: relation,
        transition: transition,
        completion: { event in
          continuation.resume(returning: event)
        }
      )
    }
    
  }
  
  /**
   
   It guarantees a given view controller will get a reference to the parent view controller after this operation immediately.
   */
  public func fluidPush(
    _ viewController: FluidPopoverViewController,
    target strategy: UIViewController.FluidStackFindStrategy,
    transition: AnyAddingTransition? = nil,
    completion: (@MainActor (AddingTransitionContext.CompletionEvent) -> Void)? = nil
  ) {
    
    let transaction = Fluid.Transaction.current
    
    transaction.removingInteraction.map {
      viewController.removingInteraction = $0
    }
    
    transaction.removingTransition.map {
      viewController.removingTransition = $0
    }
    
    fluidPushUnsafely(
      viewController,
      target: transaction.stackFindStrategy ?? strategy,
      transition: transaction.addingTransition ?? transition,
      afterViewDidLoad: {},
      completion: completion
    )
    
  }
  
  /**
   
   It guarantees a given view controller will get a reference to the parent view controller after this operation immediately.
   */
  @discardableResult
  public func fluidPush(
    _ viewController: FluidPopoverViewController,
    target strategy: UIViewController.FluidStackFindStrategy,
    transition: AnyAddingTransition? = nil
  ) async -> AddingTransitionContext.CompletionEvent {
    
    await withCheckedContinuation { continuation in
      fluidPush(
        viewController,
        target: strategy,
        transition: transition,
        completion: { event in
          continuation.resume(returning: event)
        }
      )
    }
         
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
    removingRule: RemovingRule = .cascade,
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
      removingRule: removingRule,
      completion: completion
    )
    
  }
  
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
  @discardableResult
  public func fluidPop(
    transition: AnyRemovingTransition? = nil,
    transitionForBatch: AnyBatchRemovingTransition? = .crossDissolve,
    forwardingToParent: Bool = true,
    removingRule: RemovingRule = .cascade
  ) async -> RemovingTransitionContext.CompletionEvent {
    
    await withCheckedContinuation { continuation in
      
      fluidPop(
        transition: transition,
        transitionForBatch: transitionForBatch,
        forwardingToParent: forwardingToParent,
        removingRule: removingRule,
        completion: { event in
          continuation.resume(returning: event)
      })
    }
    
  }
  
  private func _fluidPop(
    transition: AnyRemovingTransition?,
    transitionForBatch: AnyBatchRemovingTransition?,
    forwardingToParent: Bool,
    removingRule: RemovingRule,
    completion: ((RemovingTransitionContext.CompletionEvent) -> Void)?
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
        removingRule: removingRule,
        completion: completion
      )
      
    } else {
      
      fluidStackContext
        .removeSelf(
          removingRule: removingRule,
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
  
  /**
   Removes all view controllers that stacked from current.
   */
  public func fluidDiscardAllHirerachy() {
    
    self.presentedViewController?.dismiss(animated: false)
    
    if let stack = self as? FluidStackController {
      stack.removeAllViewController(transition: .crossDissolve)
    }
    
    for child in children {
      
      if let stack = child as? FluidStackController {
        stack.removeAllViewController(transition: .crossDissolve)
      }
      
    }
  }
}

