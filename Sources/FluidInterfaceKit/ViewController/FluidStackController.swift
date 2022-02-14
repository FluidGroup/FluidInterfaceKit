import SwiftUI
import UIKit

/// Actions that comes from ``FluidStackController``
public enum FluidStackAction {
  case didSetContext(FluidStackContext)
  case didDisplay
}

/// A struct that configures how to display in ``FluidStackController``
public struct FluidStackContentConfiguration {
  
  public enum ContentType {
    /// Allows background view offloads.
    case opaque
    /// Leaves background view controller in the hierarchy.
    case overlay
  }

  /// Specifies whether ``FluidStackController`` updates status bar appearance when displaying its target view controller.
  public var capturesStatusBarAppearance: Bool = true
  
  public var contentType: ContentType = .opaque

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
    return stackingItems.last?.viewController
  }

  /// An array of view controllers currently managed.
  /// Might be different with ``UIViewController.children``.
  public var stackingViewControllers: [UIViewController] {
    stackingItems.map { $0.viewController }
  }

  private(set) var stackingItems: [PresentedViewControllerWrapperView] = [] {
    didSet {
      Log.debug(
        .stack,
        """
        Updated Stacking: \(stackingItems.count)
        \(stackingItems.map { "  - \($0.debugDescription)" }.joined(separator: "\n"))
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
    return stackingItems.last {
      $0.viewController.fluidStackContentConfiguration.capturesStatusBarAppearance == true
    }?.viewController
  }

  open override var childForStatusBarHidden: UIViewController? {
    return stackingItems.last {
      $0.viewController.fluidStackContentConfiguration.capturesStatusBarAppearance == true
    }?.viewController
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
  ///   - view: a view that used in ``loadView()``
  ///   - contentView: a view that displays as first view in hierarchy of ``UIViewController/view``
  ///   - configuration: ``Configuration-swift.struct``
  ///   - rootViewController: Adds as a first content
  public init(
    identifier: Identifier? = nil,
    view: UIView? = nil,
    contentView: UIView? = nil,
    configuration: Configuration = .init(),
    rootViewController: UIViewController? = nil
  ) {
    self.identifier = identifier
    self.__rootView = view
    self.contentView = contentView ?? .init()
    self.configuration = configuration
    
    super.init(nibName: nil, bundle: nil)

    self.view.accessibilityIdentifier = "FluidStack.\(identifier?.rawValue ?? "unnamed")"
    
    if let rootViewController = rootViewController {
      addContentViewController(rootViewController, transition: .noAnimation)
    }
    
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

    guard let wrapperView = stackingItems.last else {
      Log.error(.stack, "The last view controller was not found to remove")
      return
    }

    removeViewController(wrapperView.viewController, transition: transition)
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
    
    // Trigger `viewDidLoad` explicitly.
    viewControllerToAdd.loadViewIfNeeded()
      
    // set a context if not set
    if viewControllerToAdd.fluidStackContext == nil {
      let context = FluidStackContext(
        fluidStackController: self,
        targetViewController: viewControllerToAdd
      )
      // set context
      viewControllerToAdd.fluidStackContext = context
    }
    
    let wrapperView: PresentedViewControllerWrapperView
    
    if let currentWrapperView = viewControllerToAdd.view.superview as? PresentedViewControllerWrapperView {
      // reuse
      wrapperView = currentWrapperView
    } else {
      // create new one
      let containerView = PresentedViewControllerWrapperView(
        viewController: viewControllerToAdd,
        frame: self.view.bounds
      )
      wrapperView = containerView
    }

    if viewControllerToAdd.parent != self {
      
      addChild(viewControllerToAdd)
      
      viewControllerToAdd.view.resetToVisible()
      
      viewControllerToAdd.didMove(toParent: self)
      
    } else {
      // case of adding while removing
      // TODO: might something needed
    }
    
    view.addSubview(wrapperView)
    
    // take before modifying.
    let currentTop = stackingItems.last
    
    // Adds the view controller at the latest position.
    do {
      stackingItems.removeAll { $0.viewController == viewControllerToAdd }
      stackingItems.append(wrapperView)
    }

    viewControllerToAdd.fluidStackActionHandler?(.didDisplay)

    assert(viewControllerToAdd.view.superview != nil)
    assert(viewControllerToAdd.view.superview is PresentedViewControllerWrapperView)

    let newTransitionContext = AddingTransitionContext(
      contentView: wrapperView,
      fromViewController: currentTop?.viewController,
      toViewController: viewControllerToAdd,
      onAnimationCompleted: { [weak self] context in
                        
        // MARK: Handling after animation
        
        assert(Thread.isMainThread)
        
        guard let self = self else { return }

        guard context.isInvalidated == false else {
          Log.debug(.stack, "\(context) was invalidated, skips adding")
          return
        }

        self.setTransitionContext(viewController: viewControllerToAdd, context: nil)
           
        if self.state.latestAddingTransitionContext == context {
          // handling offload
          if self.configuration.isOffloadViewsEnabled {
            self.updateOffloadingItems()
          }
        }
        
        context.transitionSucceeded()

      }
    )
    
    // To run offloading after latest adding transition.
    // it won't run if got invalidation by started removing-transition.
    state.latestAddingTransitionContext = newTransitionContext

    newTransitionContext.addCompletionEventHandler { event in
      completion(event)
    }

    // Invalidate current transition before start new transition
    // to prevent overlapping cleanup operations by completion handlers in transition context.
    // For instance, when animating for adding, then interrupted by cleanup operation.
    transitionContext(viewController: viewControllerToAdd)?.invalidate()
    setTransitionContext(viewController: viewControllerToAdd, context: newTransitionContext)

    // Start transition after invalidated current transition.
    do {

      // Turns off touch through to prevent the user attempt to start another adding-transition.
      // `Flexible` means the user can dispatch cancel in the current transition.
      wrapperView.isTouchThroughEnabled = false

      if let transition = transition {

        transition.startTransition(context: newTransitionContext)
      } else if let transitionViewController = viewControllerToAdd as? FluidTransitionViewController
      {

        transitionViewController.startAddingTransition(
          context: newTransitionContext
        )
      } else {
        AnyAddingTransition.noAnimation.startTransition(context: newTransitionContext)
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
       viewControllerToRemove == stackingItems.first?.viewController
    {
      Log.error(
        .stack,
        "the stacking will broke. Attempted to remove the view controller which displaying as root view controller. but the configuration requires to retains the root view controller."
      )
    }
    
    guard let viewToRemove = stackingItems.first(where: { $0.viewController == viewControllerToRemove }) else {
      preconditionFailure("Not found wrapper view to manage \(viewControllerToRemove)")
    }

    return _startRemoving(viewToRemove)
  }

  /**
   Starts removing transaction.
   Make sure to complete the transition with the context.
   */
  private func _startRemoving(
    _ viewToRemove: PresentedViewControllerWrapperView
  ) -> RemovingTransitionContext {

    // Ensure it's managed
    guard
      let index = stackingItems.firstIndex(of: viewToRemove)
    else {
      Log.error(.stack, "\(viewToRemove.viewController) was not found to remove")
      fatalError()
    }

    // finds a view controller that will be displayed next.
    let backView: PresentedViewControllerWrapperView? = {
      let target = index.advanced(by: -1)
      if stackingItems.indices.contains(target) {
        return stackingItems[target]
      } else {
        return nil
      }
    }()
    
    let newTransitionContext = RemovingTransitionContext(
      contentView: viewToRemove,
      fromViewController: viewToRemove.viewController,
      toViewController: backView?.viewController,
      onAnimationCompleted: { [weak self] context in

        guard let self = self else { return }

        guard context.isInvalidated == false else {
          Log.debug(.stack, "\(context) was invalidated, skips removing")
          return
        }

        /**
         Completion of transition, cleaning up
         */

        let viewControllerToRemove = viewToRemove.viewController
        self.setTransitionContext(viewController: viewControllerToRemove, context: nil)
        self.stackingItems.removeAll { $0.viewController == viewControllerToRemove }
        viewControllerToRemove.fluidStackContext = nil

        viewControllerToRemove.willMove(toParent: nil)
        viewControllerToRemove.removeFromParent()
        viewToRemove.removeFromSuperview()

        context.transitionSucceeded()

      },
      onRequestedDisplayOnTop: { [weak self] source in

        guard let self = self else {
          assertionFailure("FluidStackController has been already deallocated.")
          return .init(run: {})
        }

        return self.addPortalView(for: source, on: viewToRemove)
      }
    )

    // To enable through to make back view controller can be interactive.
    // Consequently, the user can start another transition.
    viewToRemove.isTouchThroughEnabled = true
    
    // handling offload
    if self.configuration.isOffloadViewsEnabled {
      updateOffloadingItems(displayItem: backView ?? viewToRemove)
    }
    
    // invalidates a current transition (mostly adding transition)
    // it's important to do this before starting a new transition.
    transitionContext(viewController: viewToRemove.viewController)?.invalidate()
    // set a new context to receive invalidation from transition for adding started while removing.
    setTransitionContext(viewController: viewToRemove.viewController, context: newTransitionContext)

    return newTransitionContext
  }
  
  public func canRemove(viewController: UIViewController) -> Bool {
    
    if configuration.retainsRootViewController,
       viewController == stackingItems.first?.viewController
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
        
    if stackingItems.last?.viewController != viewControllerToRemove {
      Log.error(
        .stack,
        "The removing view controller is not displaying on top. the screen won't change at the look, but the stack will change."
      )
    }
    
    guard let viewToRemove = stackingItems.first(where: { $0.viewController == viewControllerToRemove }) else {
      assertionFailure("Not found wrapper view to manage \(viewControllerToRemove)")
      return
    }

    let transitionContext = _startRemoving(viewToRemove)

    if let transition = transition {
      transition.startTransition(context: transitionContext)
    } else if let transitionViewController = viewToRemove.viewController
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
      guard let target = stackingItems.dropFirst().first else { return }
      removeAllViewController(from: target.viewController, transition: transition)
    } else {
      guard let target = stackingItems.first else { return }
      removeAllViewController(from: target.viewController, transition: transition)
    }
  }

  /**
   Removes all view controllers which displaying on top of the given view controller.
   
   - FIXME
     - Supports re-entrant operation - adding-transition. It's undefined behavior to get adding while removing.

   - Parameters:
     - from:
     - transition:
   */
  private func removeAllViewController(
    from viewController: UIViewController,
    transition: AnyBatchRemovingTransition?
  ) {

    Log.debug(.stack, "Remove \(viewController) from \(stackingItems)")

    assert(Thread.isMainThread)
    
    let targetStackingItems = stackingItems

    guard let index = targetStackingItems.firstIndex(where: { $0.viewController == viewController }) else {
      Log.error(.stack, "\(viewController) was not found to remove")
      return
    }

    let targetTopItem = targetStackingItems[0..<(index)].last

    let itemsToRemove = Array(
      targetStackingItems[
        index...stackingItems.indices.last!
      ]
    )

    assert(itemsToRemove.count > 0)
    
    let transition: AnyBatchRemovingTransition = transition ?? .noAnimation
    
    let newTransitionContext = BatchRemovingTransitionContext(
      contentView: itemsToRemove.first!,
      fromViewControllers: itemsToRemove.map(\.viewController),
      toViewController: targetTopItem?.viewController,
      onCompleted: { [weak self] context in
        
        assert(Thread.isMainThread)
        
        guard let self = self else { return }
        
        /**
         Completion of transition, cleaning up
         */
        
        for itemToRemove in itemsToRemove {
          
          self.setTransitionContext(viewController: itemToRemove.viewController, context: nil)
          
          itemToRemove.viewController.willMove(toParent: nil)
          itemToRemove.removeFromSuperview()
          itemToRemove.viewController.removeFromParent()
          itemToRemove.viewController.fluidStackContext = nil
          
          self.stackingItems.removeAll { instance in
            (instance as PresentedViewControllerWrapperView) == (itemToRemove as PresentedViewControllerWrapperView)
          }
        }
                      
        context.transitionSucceeded()
        
      }
    )
    
    for itemToRemove in itemsToRemove {
      transitionContext(viewController: itemToRemove.viewController)?.invalidate()
      setTransitionContext(
        viewController: itemToRemove.viewController,
        context: newTransitionContext
      )
    }
    
    if let targetTopItem = targetTopItem {
      updateOffloadingItems(displayItem: targetTopItem)
    }
    
    transition.startTransition(context: newTransitionContext)
    
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
     
  private func updateOffloadingItems() {
    
    let items = stackingItems
    
    guard let last = items.last else {
      // seems no there to update offloading.
      return
    }
    
    updateOffloadingItems(displayItem: last)
    
  }
  
  /**
   Offloads view controllers which do not need to display from their wrapper view.
   */
  private func updateOffloadingItems(displayItem: PresentedViewControllerWrapperView) {
    
    let items = stackingItems
    
    var order: [(PresentedViewControllerWrapperView, Bool)] = []
          
    var offloads: Bool = false
    var isInBehindDisplayItem: Bool = false
        
    for item in items.reversed() {
      
      if isInBehindDisplayItem {
        if offloads {
          order.append((item, true))
        } else {
          order.append((item, false))
          
          switch item.viewController.fluidStackContentConfiguration.contentType {
          case .opaque:
            offloads = true
          case .overlay:
            break
          }
        }
      } else {
        order.append((item, false))
        switch item.viewController.fluidStackContentConfiguration.contentType {
        case .opaque:
          offloads = true
        case .overlay:
          offloads = false
        }
        isInBehindDisplayItem = item == displayItem
      }
            
    }
    
    Log.debug(.stack, "Update offloading:\n\(order.map { "\($0.0 == displayItem ? "->" : "  ") \($0.1 ? "off" : "on ") \($0.0.viewController.fluidStackContentConfiguration.contentType)" }.joined(separator: "\n"))")
    
    for (item, offloads) in order {
      if offloads {
        item.offloadViewController()
      } else {
        item.loadViewController()
      }
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
    
    /// Keeps hodling a root view controller.
    public var retainsRootViewController: Bool
    
    /// Offloads background view controllers from hierarchy.
    public var isOffloadViewsEnabled: Bool

    public init(
      retainsRootViewController: Bool = true,
      isOffloadViewsEnabled: Bool = true
    ) {
      self.retainsRootViewController = retainsRootViewController
      self.isOffloadViewsEnabled = isOffloadViewsEnabled
    }

  }

  final class PresentedViewControllerWrapperView: UIView {
    
    private(set) var isLoaded: Bool = true

    var isTouchThroughEnabled = true
    
    let viewController: UIViewController

    init(
      viewController: UIViewController,
      frame: CGRect
    ) {
      
      self.viewController = viewController
      
      super.init(frame: frame)

      backgroundColor = .clear
      
      loadViewController()
    }
    
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    func loadViewController() {
      assert(Thread.isMainThread)
      
      isLoaded = true
      
      if let superview = viewController.view.superview {
        assert(superview == self)
      } else {
        addSubview(viewController.view)
        Fluid.setFrameAsIdentity(frame, for: viewController.view)
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
      }
    }
    
    func offloadViewController() {
      
      assert(Thread.isMainThread)
      
      isLoaded = false
      
      viewController.view.removeFromSuperview()
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
    weak var latestAddingTransitionContext: AddingTransitionContext?
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
