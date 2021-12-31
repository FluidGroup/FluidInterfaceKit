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

open class ZStackViewController: UIViewController {

  private struct State: Equatable {

  }

  private var state: State = .init()
  private let __rootView: UIView?

  public var stackingViewControllers: [ViewControllerZStackContentType] = []

  final class ViewControllerStateToken: Equatable {

    static func == (lhs: ZStackViewController.ViewControllerStateToken, rhs: ZStackViewController.ViewControllerStateToken) -> Bool {
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

    viewControllerToRemove.zStackViewControllerContext = nil
  }

  /**
   Displays a view controller
   */
  public func addContentViewController(
    _ viewControllerToAdd: ViewControllerZStackContentType,
    transition: AnyAddingTransition?
  ) {

    /**
     possible to enter while previous adding operation.
     adding -> removing(interruption) -> adding(interruption) -> dipslay(completed)
     */

    assert(Thread.isMainThread)

//    guard stackingViewControllers.contains(viewControllerToAdd) == false else {
//      Log.error(.zStack, "\(viewControllerToAdd) has been already added in ZStackViewController")
//      return
//    }

    let backViewController = stackingViewControllers.last
    stackingViewControllers.removeAll { $0 == viewControllerToAdd }
    stackingViewControllers.append(viewControllerToAdd)

    if viewControllerToAdd.zStackViewControllerContext == nil {
      /// set context
      viewControllerToAdd.zStackViewControllerContext = .init(
        zStackViewController: self,
        targetViewController: viewControllerToAdd
      )
    }

    if viewControllerToAdd.parent != self {
      addChild(viewControllerToAdd)

      let containerView = PassthoroughView()

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
  public func startRemoving(_ viewControllerToRemove: ViewControllerZStackContentType) -> RemovingTransitionContext {

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
        viewControllerToRemove.zStackViewControllerContext = nil

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
    _ viewControllerToRemove: ViewControllerZStackContentType,
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

public struct ZStackViewControllerContext {

  public private(set) weak var zStackViewController: ZStackViewController?
  public private(set) weak var targetViewController: ViewControllerZStackContentType?

  /**
   Adds view controller to parent container if it presents.
   */
  public func addContentViewController(
    _ viewController: ViewControllerZStackContentType,
    transition: AnyAddingTransition?
  ) {
    zStackViewController?.addContentViewController(viewController, transition: transition)
  }

  public func addContentView(_ view: UIView, transition: AnyAddingTransition?) {
    zStackViewController?.addContentView(view, transition: transition)
  }

  public func removeSelf(transition: AnyRemovingTransition?) {
    guard let targetViewController = targetViewController else {
      return
    }
    zStackViewController?.removeViewController(targetViewController, transition: transition)
  }

  /**
   Starts transition for removing if parent container presents.
   */
  public func startRemoving() -> RemovingTransitionContext? {
    guard let targetViewController = targetViewController else {
      return nil
    }
    return zStackViewController?.startRemoving(targetViewController)
  }

}

var ref: Void?

public protocol ViewControllerZStackContentType: UIViewController {
  var zStackViewControllerContext: ZStackViewControllerContext? { get }
}

extension ViewControllerZStackContentType {

  public internal(set) var zStackViewControllerContext: ZStackViewControllerContext? {
    get {

      guard let object = objc_getAssociatedObject(self, &ref) as? ZStackViewControllerContext else {

        guard let compatibleParent = parent as? ViewControllerZStackContentType else {
          return nil
        }
        return compatibleParent.zStackViewControllerContext
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

private final class AnonymousViewController: UIViewController, ViewControllerZStackContentType {

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
