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
    afterViewDidLoad: @escaping () -> Void = {},
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
    afterViewDidLoad: @escaping () -> Void = {}
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
    
    let current = Fluid.LocalEnvironmentValues.current
    let overriddenRelation = current.relation
    let overriddenAddingTransition = current.addingTransition
    let overridenStrategy = current.stackFindStrategy
         
    fluidPushUnsafely(
      viewController,
      target: overridenStrategy ?? strategy,
      transition: overriddenAddingTransition ?? transition,
      afterViewDidLoad: { [weak viewController] in
        viewController?.willTransition(with: overriddenRelation ?? relation)
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
    
    fluidPushUnsafely(
      viewController,
      target: strategy,
      transition: transition,
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
    
    await fluidPushUnsafely(
      viewController,
      target: strategy,
      transition: transition,
      afterViewDidLoad: {}
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
    forwardingToParent: Bool = true
  ) async -> RemovingTransitionContext.CompletionEvent {
    
    await withCheckedContinuation { continuation in
      
      fluidPop(
        transition: transition,
        transitionForBatch: transitionForBatch,
        forwardingToParent: forwardingToParent,
        completion: { event in
          continuation.resume(returning: event)
      })
    }
    
  }
  
  private func _fluidPop(
    transition: AnyRemovingTransition?,
    transitionForBatch: AnyBatchRemovingTransition?,
    forwardingToParent: Bool,
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

