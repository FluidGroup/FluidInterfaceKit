import SwiftUI
import UIKit

public enum FluidStackAction {
  case didSetContext(FluidStackContext)
  case didDisplay
}

/// A container view controller that manages view controller and view as child view controllers.
/// It provides transitions when adding and removing.
///
/// You may create subclass of this to make a first view.
///
/// Passing an identifier on initializing, make it could be found in hierarchy.
/// Use `UIViewController.fluidStackController(with: )` to find.
open class FluidStackController: UIViewController {

  // MARK: - Nested types

  /// A wrapper object that stores an string value that identifies a instance of ``FluidStackController``.
  public struct Identifier: Hashable {

    public let rawValue: String

    public init(_ rawValue: String) {
      self.rawValue = rawValue
    }

  }

  public struct Configuration {

    public var retainsRootViewController: Bool

    public init(retainsRootViewController: Bool = false) {
      self.retainsRootViewController = retainsRootViewController
    }

  }

  private final class WrapperView: UIView {

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
      let view = super.hitTest(point, with: event)
      if view == self {
        return nil
      } else {
        return view
      }
    }

  }

  private final class RootContentView: UIView {
  }

  private struct State: Equatable {

  }

  // MARK: - Properties

  /// A configuration
  public let configuration: Configuration

  /// an string value that identifies the instance of ``FluidStackController``.
  public var identifier: Identifier?

  /// A content view that stays in back
  public let contentView: UIView

  /// An array of view controllers currently managed.
  /// Might be different with ``UIViewController.children``.
  public private(set) var stackingViewControllers: [UIViewController] = [] {
    didSet {
      Log.debug(
        .stack,
        """
        Updated Stacking: \(stackingViewControllers.count)
        \(stackingViewControllers.map { "  - \($0.debugDescription)" }.joined(separator: "\n"))
        """
      )
      // TODO: Update with animation
      setNeedsStatusBarAppearanceUpdate()
    }
  }

  private var state: State = .init()

  private let __rootView: UIView?

  private var viewControllerStateMap: NSMapTable<UIViewController, TransitionContext> =
    .weakToStrongObjects()

  open override var childForStatusBarStyle: UIViewController? {
    return stackingViewControllers.last
  }

  open override var childForStatusBarHidden: UIViewController? {
    return stackingViewControllers.last
  }

  open override func loadView() {
    if let __rootView = __rootView {
      view = __rootView
    } else {
      super.loadView()
    }
  }

  // MARK: - Initializers

  public init(
    identifier: Identifier? = nil,
    view: UIView? = nil,
    configuration: Configuration = .init()
  ) {
    self.identifier = identifier
    self.__rootView = view
    self.contentView = RootContentView()
    self.configuration = configuration
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  public required init?(
    coder: NSCoder
  ) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Functions

  open override func viewDidLoad() {
    super.viewDidLoad()

    view.accessibilityIdentifier = "Fluid.Stack"

    view.addSubview(contentView)
    contentView.frame = view.bounds
    contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
  }

  public func makeFluidStackDispatchContext() -> FluidStackDispatchContext {
    .init(
      fluidStackController: self
    )
  }

  /**
   Removes the view controller displayed on most top.
   */
  public func removeLastViewController(transition: AnyRemovingTransition?) {

    assert(Thread.isMainThread)

    guard let viewControllerToRemove = stackingViewControllers.last else {
      Log.error(.stack, "The last view controller was not found to remove")
      return
    }

    removeViewController(viewControllerToRemove, transition: transition)

    viewControllerToRemove.fluidStackContext = nil
  }

  /**
   Add a view controller to display

   - Parameters:
     - transition:
       a transition for adding. if view controller is type of ``TransitionViewController``, uses this transition instead of TransitionViewController's transition.
       You may set ``.noAnimation`` to disable animation
   */
  @discardableResult
  public func addContentViewController(
    _ viewControllerToAdd: UIViewController,
    transition: AnyAddingTransition?
  ) -> FluidStackContext {

    /**
     possible to enter while previous adding operation.
     adding -> removing(interruption) -> adding(interruption) -> dipslay(completed)
     */

    assert(Thread.isMainThread)

    let backViewController = stackingViewControllers.last
    stackingViewControllers.removeAll { $0 == viewControllerToAdd }
    stackingViewControllers.append(viewControllerToAdd)
    
    let context = FluidStackContext(fluidStackController: self, targetViewController: viewControllerToAdd)

    // set a context if not set
    if viewControllerToAdd.fluidStackContext == nil {
      // set context
      viewControllerToAdd.fluidStackContext = context
    }

    if viewControllerToAdd.parent != self {
      addChild(viewControllerToAdd)

      let containerView = WrapperView()
      containerView.backgroundColor = .clear

      containerView.addSubview(viewControllerToAdd.view)
      containerView.frame = self.view.bounds
      containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

      viewControllerToAdd.view.resetToVisible()
      viewControllerToAdd.view.frame = self.view.bounds
      viewControllerToAdd.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

      view.addSubview(containerView)

      viewControllerToAdd.didMove(toParent: self)
    } else {
      // case of adding while removing
      // TODO: might something needed
    }

    viewControllerToAdd.fluidStackActionHandler?(.didDisplay)

    let transitionContext = AddingTransitionContext(
      contentView: viewControllerToAdd.view.superview!,
      fromViewController: backViewController,
      toViewController: viewControllerToAdd,
      onCompleted: { [weak self] context in

        guard let self = self else { return }

        guard context.isInvalidated == false else {
          Log.debug(.stack, "\(context) was invalidated, skips adding")
          return
        }

        self.setTransitionContext(viewController: viewControllerToAdd, context: nil)
        context.transitionFinished()

      }
    )

    self.transitionContext(viewController: viewControllerToAdd)?.invalidate()
    setTransitionContext(viewController: viewControllerToAdd, context: transitionContext)

    if let transition = transition {

      transition.startTransition(context: transitionContext)
    } else if let transitionViewController = viewControllerToAdd as? TransitionViewController {

      transitionViewController.startAddingTransition(
        context: transitionContext
      )
    } else {
      AnyAddingTransition.noAnimation.startTransition(context: transitionContext)
    }

    return context
  }

  /**
   Add a view to display with wrapping internal view controller.

   - Parameters:
     - transition: You may set ``.noAnimation`` to disable transition animation.
   */
  @discardableResult
  public func addContentView(_ view: UIView, transition: AnyAddingTransition?) -> FluidStackContext {

    assert(Thread.isMainThread)

    let viewController = ContentWrapperViewController(view: view)
    return addContentViewController(viewController, transition: transition)

  }

  /**
   Starts removing transaction for interaction.
   Make sure to complete the transition with the context.
   */
  public func startRemovingForInteraction(
    _ viewControllerToRemove: UIViewController
  ) -> RemovingTransitionContext {

    // Handles configuration
    if configuration.retainsRootViewController,
      viewControllerToRemove == stackingViewControllers.first
    {
      Log.error(
        .stack,
        "the stacking will broke. Attempted to remove the view controller which displaying as root view controller. but the configuration requires to retains the root view controller."
      )
    }

    return _startRemoving(viewControllerToRemove)
  }

  /**
   Starts removing transaction.
   Make sure to complete the transition with the context.
   */
  private func _startRemoving(
    _ viewControllerToRemove: UIViewController
  ) -> RemovingTransitionContext {

    // Ensure it's managed
    guard
      let index = stackingViewControllers.firstIndex(of: viewControllerToRemove)
    else {
      Log.error(.stack, "\(viewControllerToRemove) was not found to remove")
      fatalError()
    }

    // finds a view controller that will be displayed next.
    let backViewController: UIViewController? = {
      let target = index.advanced(by: -1)
      if stackingViewControllers.indices.contains(target) {
        return stackingViewControllers[target]
      } else {
        return nil
      }
    }()

    let newTransitionContext = RemovingTransitionContext(
      contentView: viewControllerToRemove.view.superview!,
      fromViewController: viewControllerToRemove,
      toViewController: backViewController,
      onCompleted: { [weak self] context in

        guard let self = self else { return }

        guard context.isInvalidated == false else {
          Log.debug(.stack, "\(context) was invalidated, skips removing")
          return
        }

        /**
         Completion of transition, cleaning up
         */

        self.setTransitionContext(viewController: viewControllerToRemove, context: nil)

        self.stackingViewControllers.removeAll { $0 == viewControllerToRemove }
        viewControllerToRemove.fluidStackContext = nil

        viewControllerToRemove.willMove(toParent: nil)
        viewControllerToRemove.view.superview!.removeFromSuperview()
        viewControllerToRemove.removeFromParent()

        context.transitionFinished()

      }
    )

    // invalidates a current transition (mostly adding transition)
    transitionContext(viewController: viewControllerToRemove)?.invalidate()
    // set a new context to receive invalidation from transition for adding started while removing.
    setTransitionContext(viewController: viewControllerToRemove, context: newTransitionContext)

    return newTransitionContext
  }

  /**
   Removes given view controller with transition
   */
  public func removeViewController(
    _ viewControllerToRemove: UIViewController,
    transition: AnyRemovingTransition?
  ) {

    // Handles configuration
    guard configuration.retainsRootViewController,
      viewControllerToRemove != stackingViewControllers.first
    else {
      Log.error(
        .stack,
        "Attempted to remove the view controller which displaying as root view controller. but the configuration requires to retains the root view controller."
      )
      return
    }

    if stackingViewControllers.last != viewControllerToRemove {
      // TODO: raises warning about the given view controller is not displaying on top.
    }

    let transitionContext = _startRemoving(viewControllerToRemove)

    if let transition = transition {
      transition.startTransition(context: transitionContext)
    } else if let transitionViewController = viewControllerToRemove as? TransitionViewController {
      transitionViewController.startRemovingTransition(context: transitionContext)
    } else {
      transitionContext.notifyCompleted()
    }

  }

  /**
   Removes all view controllers which are displaying

   - Parameters:
     - leavesRoot: If true, the first view controller will still be alive.
   */
  public func removeAllViewController(
    transition: AnyBatchRemovingTransition?
  ) {

    if configuration.retainsRootViewController {
      guard let target = stackingViewControllers.prefix(2).last else { return }
      removeAllViewController(from: target, transition: transition)
    } else {
      guard let target = stackingViewControllers.first else { return }
      removeAllViewController(from: target, transition: transition)
    }
  }

  /**
   Removes all view controllers which displaying on top of the given view controller.

   - Parameters:
     - from:
     - transition:
   */
  public func removeAllViewController(
    from viewController: UIViewController,
    transition: AnyBatchRemovingTransition?
  ) {

    Log.debug(.stack, "Remove \(viewController) from \(stackingViewControllers)")

    assert(Thread.isMainThread)

    guard let index = stackingViewControllers.firstIndex(where: { $0 == viewController }) else {
      Log.error(.stack, "\(viewController) was not found to remove")
      return
    }

    let targetTopViewController: UIViewController? = stackingViewControllers[0..<(index)].last

    let viewControllersToRemove = Array(
      stackingViewControllers[
        index...stackingViewControllers.indices.last!
      ]
    )

    assert(viewControllersToRemove.count > 0)

    if let transition = transition {

      viewControllersToRemove.forEach {
        $0.willMove(toParent: nil)
        $0.removeFromParent()
      }

      let newTransitionContext = BatchRemovingTransitionContext(
        contentView: viewControllersToRemove.first!.view.superview!,
        fromViewControllers: viewControllersToRemove,
        toViewController: targetTopViewController,
        onCompleted: { [weak self] context in

          guard let self = self else { return }

          /**
           Completion of transition, cleaning up
           */

          for viewControllerToRemove in viewControllersToRemove
          where context.isInvalidated(for: viewControllerToRemove) == false {
            self.setTransitionContext(viewController: viewControllerToRemove, context: nil)
            viewControllerToRemove.willMove(toParent: nil)
            viewControllerToRemove.view.superview!.removeFromSuperview()
            viewControllerToRemove.removeFromParent()
            viewControllerToRemove.fluidStackContext = nil
          }

          self.stackingViewControllers.removeAll { instance in
            viewControllersToRemove.contains(where: { $0 == instance })
          }

          context.transitionFinished()

        }
      )

      for viewControllerToRemove in viewControllersToRemove {
        transitionContext(viewController: viewControllerToRemove)?.invalidate()
        setTransitionContext(
          viewController: viewControllerToRemove,
          context: newTransitionContext.child(for: viewControllerToRemove)
        )
      }

      transition.startTransition(context: newTransitionContext)

    } else {

      while stackingViewControllers.last != targetTopViewController {

        let viewControllerToRemove = stackingViewControllers.last!
        transitionContext(viewController: viewControllerToRemove)?.invalidate()
        setTransitionContext(viewController: viewControllerToRemove, context: nil)

        assert(stackingViewControllers.last === viewControllerToRemove)

        viewControllerToRemove.willMove(toParent: nil)
        viewControllerToRemove.view.removeFromSuperview()
        viewControllerToRemove.removeFromParent()

        stackingViewControllers.removeLast()

      }

    }

  }

  private func setTransitionContext(
    viewController: UIViewController,
    context: TransitionContext?
  ) {
    viewControllerStateMap.setObject(context, forKey: viewController)
  }

  private func transitionContext(
    viewController: UIViewController
  ) -> TransitionContext? {
    viewControllerStateMap.object(forKey: viewController)
  }

}

public struct FluidStackDispatchContext {

  public private(set) weak var fluidStackController: FluidStackController?

  public func addContentViewController(
    _ viewController: UIViewController,
    transition: AnyAddingTransition?
  ) {
    fluidStackController?.addContentViewController(viewController, transition: transition)
  }

  public func addContentView(_ view: UIView, transition: AnyAddingTransition?) {
    fluidStackController?.addContentView(view, transition: transition)
  }

}

/**
 A context object that communicates with ``FluidStackController``.
 Associated with the view controller displayed on the stack.
 */
public struct FluidStackContext {

  public private(set) weak var fluidStackController: FluidStackController?
  public private(set) weak var targetViewController: UIViewController?

  /**
   Adds view controller to parent container if it presents.
   */
  public func addContentViewController(
    _ viewController: UIViewController,
    transition: AnyAddingTransition?
  ) {
    fluidStackController?.addContentViewController(viewController, transition: transition)
  }

  public func addContentView(_ view: UIView, transition: AnyAddingTransition?) {
    fluidStackController?.addContentView(view, transition: transition)
  }

  /// Removes the target view controller in ``FluidStackController``.
  /// - Parameter transition: if not nil, it would be used override parameter.
  ///
  /// See detail in ``FluidStackController/removeViewController(_:transition:)``
  public func removeSelf(transition: AnyRemovingTransition?) {
    guard let targetViewController = targetViewController else {
      return
    }
    fluidStackController?.removeViewController(targetViewController, transition: transition)
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

var ref: Void?

private var fluidActionHandlerRef: Void?

extension UIViewController {

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

}

extension UIViewController {

  /// [Get]: Returns a stored instance or nearest parent's one.
  /// [Set]: Stores given instance.
  public internal(set) var fluidStackContext: FluidStackContext? {
    get {

      guard let object = objc_getAssociatedObject(self, &ref) as? FluidStackContext else {
        return parent?.fluidStackContext
      }
      return object

    }
    set {

      objc_setAssociatedObject(
        self,
        &ref,
        newValue,
        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
      )

      if let newValue = newValue {
        fluidStackActionHandler?(.didSetContext(newValue))
      }
    }

  }
}

extension FluidStackController {

  private final class ContentWrapperViewController: UIViewController {

    private let __rootView: UIView

    override func loadView() {
      view = __rootView
    }

    init(
      view: UIView
    ) {
      self.__rootView = view
      super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    public required init?(
      coder: NSCoder
    ) {
      fatalError("init(coder:) has not been implemented")
    }
  }

}
