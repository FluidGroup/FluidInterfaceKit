import UIKit
import SwiftUI

private final class PassthoroughView: UIView {

  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    let view = super.hitTest(point, with: event)
    if view == self {
      return nil
    } else {
      return view
    }
  }

}

/**
 A container view controller that manages view controller and view as child view controllers.
 It provides transitions when adding and removing.

 You may create subclass of this to make a first view.
 */
open class FluidStackViewController: UIViewController {

  private struct State: Equatable {

  }

  private var state: State = .init()
  private let __rootView: UIView?

  public var stackingViewControllers: [ViewControllerFluidContentType] = []

  final class ViewControllerStateToken: Equatable {

    static func == (lhs: FluidStackViewController.ViewControllerStateToken, rhs: FluidStackViewController.ViewControllerStateToken) -> Bool {
      lhs === rhs
    }

    let state: ViewControllerState

    init(state: ViewControllerState) {
      self.state = state
    }
  }

  enum ViewControllerState: Int {
    case removed
    case adding
    case added
    case removing
  }

  private var viewControllerStateMap: NSMapTable<UIViewController, TransitionContext> =
    .weakToStrongObjects()

  open override func loadView() {
    if let __rootView = __rootView {
      view = __rootView
    } else {
      super.loadView()
    }
  }

  public init(
    view: UIView? = nil
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

  open override func viewDidLoad() {
    super.viewDidLoad()
  }

  public func addContentView(_ view: UIView, transition: AnyAddingTransition?) {

    assert(Thread.isMainThread)

    let viewController = AnonymousViewController(view: view)
    addContentViewController(viewController, transition: transition)

  }

  public func removeLastViewController(transition: AnyRemovingTransition?) {

    assert(Thread.isMainThread)

    guard let viewControllerToRemove = stackingViewControllers.last else {
      Log.error(.zStack, "The last view controller was not found to remove")
      return
    }

    removeViewController(viewControllerToRemove, transition: transition)

    viewControllerToRemove.fluidStackViewControllerContext = nil
  }

  /**
   Displays a view controller

   - Parameters:
     - transition: a transition for adding. if view controller is type of ``TransitionViewController``, uses this transition instead of TransitionViewController's transition.
   */
  public func addContentViewController(
    _ viewControllerToAdd: ViewControllerFluidContentType,
    transition: AnyAddingTransition?
  ) {

    /**
     possible to enter while previous adding operation.
     adding -> removing(interruption) -> adding(interruption) -> dipslay(completed)
     */

    assert(Thread.isMainThread)

    let backViewController = stackingViewControllers.last
    stackingViewControllers.removeAll { $0 == viewControllerToAdd }
    stackingViewControllers.append(viewControllerToAdd)

    if viewControllerToAdd.fluidStackViewControllerContext == nil {
      /// set context
      viewControllerToAdd.fluidStackViewControllerContext = .init(
        fluidStackViewController: self,
        targetViewController: viewControllerToAdd
      )
    }

    if viewControllerToAdd.parent != self {
      addChild(viewControllerToAdd)

      let containerView = PassthoroughView()
      containerView.backgroundColor = .clear

      containerView.addSubview(viewControllerToAdd.view)
      containerView.frame = self.view.bounds
      containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

      viewControllerToAdd.view.transform = .identity
      viewControllerToAdd.view.frame = self.view.bounds
      viewControllerToAdd.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

      view.addSubview(containerView)

      viewControllerToAdd.didMove(toParent: self)
    } else {
      // TODO: something needed
    }

    let transitionContext = AddingTransitionContext(
      contentView: viewControllerToAdd.view.superview!,
      fromViewController: backViewController,
      toViewController: viewControllerToAdd,
      onCompleted: { [weak self] context in

        guard let self = self else { return }

        guard context.isInvalidated == false else {
          Log.debug(.zStack, "\(context) was invalidated, skips adding")
          return
        }

        self.setViewControllerState(viewController: viewControllerToAdd, context: nil)
        context.transitionFinished()

      }
    )

    viewControllerState(viewController: viewControllerToAdd)?.invalidate()
    setViewControllerState(viewController: viewControllerToAdd, context: transitionContext)

    if let transition = transition {

      transition.startTransition(context: transitionContext)
    } else if let transitionViewController = viewControllerToAdd as? TransitionViewController {

      transitionViewController.startAddingTransition(
        context: transitionContext
      )
    } else {
      transitionContext.notifyCompleted()
    }

  }

  /**
   Starts removing transaction.
   Make sure to complete the transition with the context.
   */
  public func startRemoving(_ viewControllerToRemove: ViewControllerFluidContentType) -> RemovingTransitionContext {

    guard let index = stackingViewControllers.firstIndex(where: { $0 == viewControllerToRemove}) else {
      Log.error(.zStack, "\(viewControllerToRemove) was not found to remove")
      fatalError()
    }

    let backViewController: UIViewController? = {
      let target = index.advanced(by: -1)
      if stackingViewControllers.indices.contains(target) {
        return stackingViewControllers[target]
      } else {
        return nil
      }
    }()

    let transitionContext = RemovingTransitionContext(
      contentView: viewControllerToRemove.view.superview!,
      fromViewController: viewControllerToRemove,
      toViewController: backViewController,
      onCompleted: { [weak self] context in

        guard let self = self else { return }

        guard context.isInvalidated == false else {
          Log.debug(.zStack, "\(context) was invalidated, skips removing")
          return
        }

        /**
         Completion of transition, cleaning up
         */

        self.setViewControllerState(viewController: viewControllerToRemove, context: nil)

        self.stackingViewControllers.removeAll { $0 == viewControllerToRemove }
        viewControllerToRemove.fluidStackViewControllerContext = nil

        viewControllerToRemove.willMove(toParent: nil)
        viewControllerToRemove.view.superview!.removeFromSuperview()
        viewControllerToRemove.removeFromParent()

        context.transitionFinished()

      }
    )

    viewControllerState(viewController: viewControllerToRemove)?.invalidate()
    setViewControllerState(viewController: viewControllerToRemove, context: transitionContext)

    return transitionContext
  }

  public func removeViewController(
    _ viewControllerToRemove: ViewControllerFluidContentType,
    transition: AnyRemovingTransition?
  ) {

    let transitionContext = startRemoving(viewControllerToRemove)

    if let transition = transition {
      transition.startTransition(context: transitionContext)
    } else if let transitionViewController = viewControllerToRemove as? TransitionViewController {
      transitionViewController.startRemovingTransition(context: transitionContext)
    } else {
      transitionContext.notifyCompleted()
    }

  }

  // FIXME: not completed implementation
  public func removeAllViewController(
    from viewController: UIViewController,
    transition: AnyBatchRemovingTransition?
  ) {

    Log.debug(.zStack, "Remove \(viewController) from \(stackingViewControllers)")

    assert(Thread.isMainThread)

    guard let index = stackingViewControllers.firstIndex(where: { $0 == viewController}) else {
      Log.error(.zStack, "\(viewController) was not found to remove")
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

      let context = BatchRemovingTransitionContext(
        contentView: viewControllersToRemove.first!.view.superview!,
        fromViewControllers: viewControllersToRemove,
        toViewController: targetTopViewController,
        onCompleted: { [weak self] _ in

        }
      )

      transition.startTransition(context: context)

    } else {

      while stackingViewControllers.last != targetTopViewController {

        let viewControllerToRemove = stackingViewControllers.last!

        assert(stackingViewControllers.last === viewControllerToRemove)

        viewControllerToRemove.willMove(toParent: nil)
        viewControllerToRemove.view.removeFromSuperview()
        viewControllerToRemove.removeFromParent()

        stackingViewControllers.removeLast()

      }

    }

    Log.debug(.zStack, "Removed => \(children)")

  }

  private func setViewControllerState(viewController: UIViewController, context: TransitionContext?)
  {
    viewControllerStateMap.setObject(context, forKey: viewController)
  }

  private func viewControllerState(viewController: UIViewController) -> TransitionContext? {
    viewControllerStateMap.object(forKey: viewController)
  }
}

public struct FluidStackViewControllerContext {

  public private(set) weak var fluidStackViewController: FluidStackViewController?
  public private(set) weak var targetViewController: ViewControllerFluidContentType?

  /**
   Adds view controller to parent container if it presents.
   */
  public func addContentViewController(
    _ viewController: ViewControllerFluidContentType,
    transition: AnyAddingTransition?
  ) {
    fluidStackViewController?.addContentViewController(viewController, transition: transition)
  }

  public func addContentView(_ view: UIView, transition: AnyAddingTransition?) {
    fluidStackViewController?.addContentView(view, transition: transition)
  }

  /// Removes the target view controller in ``FluidStackViewController``.
  /// - Parameter transition: if not nil, it would be used override parameter.
  public func removeSelf(transition: AnyRemovingTransition?) {
    guard let targetViewController = targetViewController else {
      return
    }
    fluidStackViewController?.removeViewController(targetViewController, transition: transition)
  }

  /**
   Starts transition for removing if parent container presents.
   */
  public func startRemoving() -> RemovingTransitionContext? {
    guard let targetViewController = targetViewController else {
      return nil
    }
    return fluidStackViewController?.startRemoving(targetViewController)
  }

}

public protocol ViewControllerFluidContentType: UIViewController {
  var fluidStackViewControllerContext: FluidStackViewControllerContext? { get }
}

var ref: Void?

extension ViewControllerFluidContentType {

  public internal(set) var fluidStackViewControllerContext: FluidStackViewControllerContext? {
    get {

      guard let object = objc_getAssociatedObject(self, &ref) as? FluidStackViewControllerContext else {

        guard let compatibleParent = parent as? ViewControllerFluidContentType else {
          return nil
        }
        return compatibleParent.fluidStackViewControllerContext
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

    }

  }
}

private final class AnonymousViewController: UIViewController, ViewControllerFluidContentType {

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
