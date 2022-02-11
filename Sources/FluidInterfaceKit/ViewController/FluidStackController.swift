import SwiftUI
import UIKit

/// Actions that comes from ``FluidStackController``
public enum FluidStackAction {
  case didSetContext(FluidStackContext)
  case didDisplay
}

/// A struct that configures how to display in ``FluidStackController``
public struct FluidStackContentConfiguration {

  /// Specifies whether ``FluidStackController`` updates status bar appearance when displaying its target view controller.
  public var capturesStatusBarAppearance: Bool = true

}

/// A container view controller that manages view controller and view as child view controllers.
/// It provides transitions when adding and removing.
///
/// You may create subclass of this to make a first view.
///
/// Passing an identifier on initializing, make it could be found in hierarchy.
/// Use ``UIViewController/fluidStackController(with: )`` to find.
open class FluidStackController: UIViewController {

  // MARK: - Properties

  /// A configuration
  public let configuration: Configuration

  /// an string value that identifies the instance of ``FluidStackController``.
  public var identifier: Identifier?

  /// A content view that stays in back
  public let contentView: UIView

  /// The view controller at the top of the stack.
  public var topViewController: UIViewController? {
    return stackingViewControllers.last
  }

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
      UIViewPropertyAnimator(duration: 0.4, dampingRatio: 1) {
        self.setNeedsStatusBarAppearanceUpdate()
      }
      .startAnimation()
    }
  }

  private var state: State = .init()

  private let __rootView: UIView?

  private var viewControllerStateMap: NSMapTable<UIViewController, TransitionContext> =
    .weakToWeakObjects()

  open override var childForStatusBarStyle: UIViewController? {
    return stackingViewControllers.last {
      $0.fluidStackContentConfiguration.capturesStatusBarAppearance == true
    }
  }

  open override var childForStatusBarHidden: UIViewController? {
    return stackingViewControllers.last {
      $0.fluidStackContentConfiguration.capturesStatusBarAppearance == true
    }
  }

  open override func loadView() {
    if let __rootView = __rootView {
      view = __rootView
    } else {
      super.loadView()
    }
  }

  // MARK: - Initializers

  /// Creates an instance
  /// - Parameters:
  ///   - identifier: ``Identifier-swift.struct`` to find the instance in hierarchy.
  ///   - view:
  ///   - configuration:
  public init(
    identifier: Identifier? = nil,
    view: UIView? = nil,
    contentView: UIView? = nil,
    configuration: Configuration = .init()
  ) {
    self.identifier = identifier
    self.__rootView = view
    self.contentView = contentView ?? .init()
    self.configuration = configuration

    super.init(nibName: nil, bundle: nil)

    self.view.accessibilityIdentifier = "FluidStack.\(identifier?.rawValue ?? "unnamed")"
  }

  @available(*, unavailable)
  public required init?(
    coder: NSCoder
  ) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Functions

  /**
   Make sure call super method when you create override.
   */
  open override func viewDidLoad() {
    super.viewDidLoad()

    view.accessibilityIdentifier = "Fluid.Stack"

    view.addSubview(contentView)

    contentView.frame = view.bounds
    contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
  }

  // TODO: Under considerations.
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
  @available(*, renamed: "addContentViewController(_:transition:)")
  public func addContentViewController(
    _ viewControllerToAdd: UIViewController,
    transition: AnyAddingTransition?,
    completion: @escaping (AddingTransitionContext.CompletionEvent) -> Void = { _ in }
  ) {

    /**
     possible to enter while previous adding operation.
     adding -> removing(interruption) -> adding(interruption) -> dipslay(completed)
     */

    assert(Thread.isMainThread)

    let currentTopViewController = stackingViewControllers.last

    // Adds the view controller at the latest position.
    do {
      stackingViewControllers.removeAll { $0 == viewControllerToAdd }
      stackingViewControllers.append(viewControllerToAdd)
    }

    let context = FluidStackContext(
      fluidStackController: self,
      targetViewController: viewControllerToAdd
    )

    // set a context if not set
    if viewControllerToAdd.fluidStackContext == nil {
      // set context
      viewControllerToAdd.fluidStackContext = context
    }

    if viewControllerToAdd.parent != self {
      addChild(viewControllerToAdd)

      let containerView = PresentedViewControllerWrapperView(
        contentView: viewControllerToAdd.view,
        frame: self.view.bounds
      )

      viewControllerToAdd.view.resetToVisible()

      view.addSubview(containerView)

      viewControllerToAdd.didMove(toParent: self)
    } else {
      // case of adding while removing
      // TODO: might something needed
    }

    viewControllerToAdd.fluidStackActionHandler?(.didDisplay)

    assert(viewControllerToAdd.view.superview != nil)
    assert(viewControllerToAdd.view.superview is PresentedViewControllerWrapperView)

    var wrapperView: PresentedViewControllerWrapperView {
      viewControllerToAdd.view.superview as! PresentedViewControllerWrapperView
    }

    let transitionContext = AddingTransitionContext(
      contentView: viewControllerToAdd.view.superview!,
      fromViewController: currentTopViewController,
      toViewController: viewControllerToAdd,
      onAnimationCompleted: { [weak self] context in

        guard let self = self else { return }

        guard context.isInvalidated == false else {
          Log.debug(.stack, "\(context) was invalidated, skips adding")
          return
        }

        self.setTransitionContext(viewController: viewControllerToAdd, context: nil)
        context.transitionSucceeded()

      }
    )

    transitionContext.addCompletionEventHandler { event in
      completion(event)
    }

    // Invalidate current transition before start new transition
    // to prevent overlapping cleanup operations by completion handlers in transition context.
    // For instance, when animating for adding, then interrupted by cleanup operation.
    self.transitionContext(viewController: viewControllerToAdd)?.invalidate()
    setTransitionContext(viewController: viewControllerToAdd, context: transitionContext)

    // Start transition after invalidated current transition.
    do {

      // Turns off touch through to prevent the user attempt to start another adding-transition.
      // `Flexible` means the user can dispatch cancel in the current transition.
      wrapperView.isTouchThroughEnabled = false

      if let transition = transition {

        transition.startTransition(context: transitionContext)
      } else if let transitionViewController = viewControllerToAdd as? FluidTransitionViewController
      {

        transitionViewController.startAddingTransition(
          context: transitionContext
        )
      } else {
        AnyAddingTransition.noAnimation.startTransition(context: transitionContext)
      }
    }

  }

  @available(iOS 13.0, *)
  @discardableResult
  @MainActor
  public func addContentViewController(
    _ viewControllerToAdd: UIViewController,
    transition: AnyAddingTransition?
  ) async -> AddingTransitionContext.CompletionEvent {
    return await withCheckedContinuation { continuation in
      addContentViewController(viewControllerToAdd, transition: transition) { result in
        continuation.resume(returning: result)
      }
    }
  }

  /**
   Add a view to display with wrapping internal view controller.

   - Parameters:
     - transition: You may set ``.noAnimation`` to disable transition animation.
   */

  public func addContentView(
    _ view: UIView,
    transition: AnyAddingTransition?,
    completion: @escaping (AddingTransitionContext.CompletionEvent) -> Void = { _ in }
  ) {

    assert(Thread.isMainThread)

    let viewController = ContentWrapperViewController(view: view)
    addContentViewController(viewController, transition: transition, completion: completion)

  }

  @available(iOS 13.0, *)
  @discardableResult
  @MainActor
  public func addContentView(
    _ view: UIView,
    transition: AnyAddingTransition?
  ) async -> AddingTransitionContext.CompletionEvent {
    return await withCheckedContinuation { continuation in
      addContentView(view, transition: transition) { result in
        continuation.resume(returning: result)
      }
    }
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

    var wrapperView: PresentedViewControllerWrapperView {
      viewControllerToRemove.view.superview as! PresentedViewControllerWrapperView
    }

    let newTransitionContext = RemovingTransitionContext(
      contentView: viewControllerToRemove.view.superview!,
      fromViewController: viewControllerToRemove,
      toViewController: backViewController,
      onAnimationCompleted: { [weak self] context in

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

        context.transitionSucceeded()

      },
      onRequestedDisplayOnTop: { [weak self] source in

        guard let self = self else {
          assertionFailure("FluidStackController has been already deallocated.")
          return .init(run: {})
        }

        return self.addPortalView(for: source, on: wrapperView)
      }
    )

    // To enable through to make back view controller can be interactive.
    // Consequently, the user can start another transition.
    wrapperView.isTouchThroughEnabled = true

    // invalidates a current transition (mostly adding transition)
    // it's important to do this before starting a new transition.
    transitionContext(viewController: viewControllerToRemove)?.invalidate()
    // set a new context to receive invalidation from transition for adding started while removing.
    setTransitionContext(viewController: viewControllerToRemove, context: newTransitionContext)

    return newTransitionContext
  }
  
  public func canRemove(viewController: UIViewController) -> Bool {
    
    if configuration.retainsRootViewController,
       viewController == stackingViewControllers.first
    {
      return false
    }

    return true
  }

  /**
   Removes given view controller with transition
   */
  public func removeViewController(
    _ viewControllerToRemove: UIViewController,
    transition: AnyRemovingTransition?
  ) {

    // Handles configuration
    
    guard canRemove(viewController: viewControllerToRemove) else {
      Log.error(
        .stack,
        "Attempted to remove the view controller which displaying as root view controller. but the configuration requires to retains the root view controller."
      )
      return
    }
    
    if configuration.retainsRootViewController,
      viewControllerToRemove == stackingViewControllers.first
    {
      
      return
    }

    if stackingViewControllers.last != viewControllerToRemove {
      Log.error(
        .stack,
        "The removing view controller is not displaying on top. the screen won't change at the look, but the stack will change."
      )
    }

    let transitionContext = _startRemoving(viewControllerToRemove)

    if let transition = transition {
      transition.startTransition(context: transitionContext)
    } else if let transitionViewController = viewControllerToRemove
      as? FluidTransitionViewController
    {
      transitionViewController.startRemovingTransition(context: transitionContext)
    } else {
      transitionContext.notifyAnimationCompleted()
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

          context.transitionSucceeded()

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

  private func addPortalView(
    for source: DisplaySource,
    on targetView: PresentedViewControllerWrapperView
  ) -> DisplayingOnTopSubscription {

    assert(Thread.isMainThread)

    let portalView = PortalView(source: source)
    portalView.frame = targetView.bounds
    portalView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    portalView.matchesPosition = true
    portalView.hidesSourceLayer = true
    portalView.matchesTransform = true
    portalView.matchesOpacity = true
    targetView.addSubview(portalView)

    return .init {
      portalView.removeFromSuperview()
    }
  }

}

// MARK: - Nested types
extension FluidStackController {

  public struct DisplayingOnTopSubscription {

    private let _run: () -> Void

    init(run: @escaping () -> Void) {
      self._run = run
    }

    public func dispose() {
      _run()
    }

  }

  /// A wrapper object that stores an string value that identifies a instance of ``FluidStackController``.
  public struct Identifier: Hashable {

    public let rawValue: String

    public init(_ rawValue: String) {
      self.rawValue = rawValue
    }

  }

  public struct Configuration {

    public var retainsRootViewController: Bool

    public init(retainsRootViewController: Bool = true) {
      self.retainsRootViewController = retainsRootViewController
    }

  }

  private final class PresentedViewControllerWrapperView: UIView {

    var isTouchThroughEnabled = true

    init(contentView: UIView, frame: CGRect) {
      super.init(frame: frame)

      addSubview(contentView)
      Fluid.setFrameAsIdentity(frame, for: contentView)
      contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      autoresizingMask = [.flexibleWidth, .flexibleHeight]

      backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

      if isTouchThroughEnabled {
        let view = super.hitTest(point, with: event)
        if view == self {
          return nil
        } else {
          return view
        }
      } else {
        return super.hitTest(point, with: event)
      }
    }

  }

  private struct State: Equatable {

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

/// A context object that communicates with ``FluidStackController``.
/// Associated with the view controller displayed on the stack.
public struct FluidStackContext {

  public private(set) weak var fluidStackController: FluidStackController?
  public private(set) weak var targetViewController: UIViewController?

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
