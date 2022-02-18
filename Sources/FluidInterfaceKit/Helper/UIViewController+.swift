import ObjectiveC
import UIKit

extension UIViewController {

  /**
   Returns all ``FluidStackController``s in hierachy of the ``UIWindow``.
   */
  public func fluidStackControllers() -> [FluidStackController] {

    /// going back using `.parent` instead of `.next` because to ignore modal-presentation.
    return sequence(first: self) {
      $0.parent
    }
    .compactMap { $0 as? FluidStackController }

  }

  public struct FluidStackFindStrategy {

    public let name: String
    
    let pick: ([FluidStackController]) -> FluidStackController?

    /// Creates an instance
    /// - Parameter where: Solves find by return true. Given instances come from the nearest one.
    public init(
      name: String,
      pick: @escaping ([FluidStackController]) -> FluidStackController?
    ) {
      self.name = name
      self.pick = pick
    }

    /// Finds by identifier
    public static func identifier(_ identifier: FluidStackController.Identifier) -> Self {
      .init(name: "identifier.\(identifier)") { stackControllers in
        stackControllers.first { $0.identifier == identifier }
      }
    }

    /**
     Finds a nearest ``FluidStackController`` including itself
     */
    public static let current: Self = {
      .init(name: "current") { controllers in
        controllers.first
      }
    }()

    /**
     Finds a nearest ``FluidStackController`` excluding itself
     */
    public static let nearestAncestor: Self = {
      .init(name: "nearestAncestor") { controllers in
        controllers.dropFirst(1).first
      }
    }()

    /**
     Finds a root ``FluidStackController`` in the UIWindow.
     */
    public static let root: Self = {
      .init(name: "root") { controllers in
        controllers.last
      }
    }()

    /// Finds by composed strategy
    public static func matching(
      name: String,
      strategies: [FluidStackFindStrategy]
    ) -> Self {
      return .init(name: name) { stackControllers in
        for strategy in strategies {
          if let found = strategy.pick(stackControllers) {
            return found
          }
        }
        return nil
      }
    }

  }

  /**
   Returns the view controller's nearest ancestor ``FluidStackController`` (including itself) with a given strategy

   ``FluidStackController`` can set an identifier on init.
   */
  public func fluidStackController(with strategy: FluidStackFindStrategy) -> FluidStackController? {

    let controllersOrderByNearest = fluidStackControllers()

    return strategy.pick(controllersOrderByNearest)

  }

}

private var fluidStackContextRef: Void?
private var fluidActionHandlerRef: Void?
private var fluidStackContentConfigurationRef: Void?

extension UIViewController {

  /// A struct that configures how to display in ``FluidStackController``
  public var fluidStackContentConfiguration: FluidStackContentConfiguration {
    get {
      (objc_getAssociatedObject(self, &fluidStackContentConfigurationRef)
        as? FluidStackContentConfiguration) ?? .init()
    }
    set {
      objc_setAssociatedObject(
        self,
        &fluidStackContentConfigurationRef,
        newValue,
        .OBJC_ASSOCIATION_COPY_NONATOMIC
      )
    }
  }

  /// A closure that ``FluidStackController`` invokes when raised activities.
  public var fluidStackActionHandler: ((FluidStackAction) -> Void)? {
    get {
      objc_getAssociatedObject(self, &fluidActionHandlerRef) as? (FluidStackAction) -> Void
    }
    set {
      objc_setAssociatedObject(
        self,
        &fluidActionHandlerRef,
        newValue,
        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
      )
    }
  }

  /// [Get]: Returns a stored instance or nearest parent's one.
  /// [Set]: Stores given instance.
  public internal(set) var fluidStackContext: FluidStackContext? {
    get {

      guard let object = objc_getAssociatedObject(self, &fluidStackContextRef) as? FluidStackContext
      else {
        if parent is FluidStackController {
          // stop find
          return nil
        }
        // continue to find from parent
        return parent?.fluidStackContext
      }
      return object

    }
    set {

      objc_setAssociatedObject(
        self,
        &fluidStackContextRef,
        newValue,
        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
      )

      if let newValue = newValue {
        fluidStackActionHandler?(.didSetContext(newValue))
      }
    }

  }
}

// MARK: Presentation and dismissal

extension UIViewController {
  
  /**
   Adds a given view controller to the target ``FluidStackController``.

   - Parameters:
     - target: Specify how to find a target to display
     - transition: You may set ``AnyAddingTransition/noAnimation`` to disable animation, nil runs transition given view controller provides (if it's ``FluidTransitionViewController``).
   */
  public func fluidPushUnsafely(
    _ viewController: UIViewController,
    target strategy: UIViewController.FluidStackFindStrategy,
    transition: AnyAddingTransition? = nil
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
      .addContentViewController(controller, transition: transition)
  
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
    transition: AnyAddingTransition? = nil
  ) {

    viewController.loadViewIfNeeded()
    
    viewController.willTransition(with: relation)

    fluidPushUnsafely(
      viewController,
      target: strategy,
      transition: transition
    )
      
  }

  /**
   Removes this view controller from the target ``FluidStackController``.

   - Parameters:
     - transition: You may set ``AnyRemovingTransition/noAnimation`` to disable animation, nil runs transition given view controller provides (if it's ``FluidTransitionViewController``).
     - fowardingToParent: Forwards to parent to pop if current stack do not have view controller to pop. No effects if the current stack prevents it by ``FluidStackController/Configuration-swift.struct/preventsFowardingPop``
   */
  public func fluidPop(
    transition: AnyRemovingTransition?,
    forwardingToParent: Bool = true,
    completion: (() -> Void)? = nil
  ) {
    
    guard next != nil else {
      // got the end of tree.
      return
    }

    guard
      let fluidStackContext = fluidStackContext,
      let _ = fluidStackContext.fluidStackController
    else {
      let message = "\(self) is not presented as fluid-presentation"
      Log.error(.viewController, message)
      return
    }

    _fluidPop(transition: transition, forwardingToParent: forwardingToParent, completion: completion)

  }
  
  private func _fluidPop(
    transition: AnyRemovingTransition?,
    forwardingToParent: Bool = true,
    completion: (() -> Void)? = nil
  ) {
    
    guard next != nil else {
      // got the end of tree.
      return
    }

    guard
      let fluidStackContext = fluidStackContext,
      let stack = fluidStackContext.fluidStackController
    else {
      return
    }

    if
      stack.configuration.preventsFowardingPop == false,
      forwardingToParent == true,
      stack.configuration.retainsRootViewController,
      stack.stackingViewControllers.first.map({ self.isDescendant(of: $0) }) == true
    {
      
      // there is no view controller to remove in current stack.
      // forwards to the parent attempt to pop itself in the stack
      
      stack._fluidPop(
        transition: transition,
        forwardingToParent: forwardingToParent,
        completion: completion
      )
     
    } else {

      fluidStackContext.removeSelf(transition: transition)
      completion?()
    }

  }

  /**
   Whether this view controller or its parent recursively is in ``FluidStackController``.
   */
  public var isInFluidStackController: Bool {
    fluidStackContext != nil
  }

}

extension UIViewController {
  
  func isDescendant(of viewController: UIViewController) -> Bool {
    
    viewController == self || viewController.children.contains(self)
    
  }
  
}

extension UIViewController {
  
  /**
   Creates ``FluidViewController`` with itself.
   
   You may use this method in ``UIViewController/fluidPush``.
   
   ```swift
   let controller: YourViewController
   
   fluidPush(controller.fluidWrapped(...), ...)
   ```
   */
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

