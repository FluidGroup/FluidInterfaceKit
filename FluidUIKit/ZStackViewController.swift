import UIKit

open class ZStackViewController: UIViewController {

  private struct State: Equatable {
  }

  private var state: State = .init()
  private let __rootView: UIView?

  public var stackingViewControllers: [UIViewController] = []
  public var reservedRemovingViewControllers: Set<UIViewController> = .init()

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

  public func addContentViewController(
    _ frontViewController: UIViewController,
    transition: AnyZStackViewControllerAddingTransition?
  ) {

    assert(Thread.isMainThread)

    guard stackingViewControllers.contains(frontViewController) == false else {
      Log.error(.zStack, "\(frontViewController) has been already added in ZStackViewController")
      return
    }

    let backViewController = stackingViewControllers.last
    stackingViewControllers.append(frontViewController)

    /// set context
    frontViewController.zStackViewControllerContext = .init(
      zStackViewController: self,
      targetViewController: frontViewController
    )

    addChild(frontViewController)
    view.addSubview(frontViewController.view)
    frontViewController.view.frame = self.view.bounds
    frontViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    if let transition = transition {

      let transitionContext = ZStackViewControllerAddingTransitionContext(
        contentView: self.view,
        fromViewController: backViewController,
        toViewController: frontViewController
      )

      transition.startTransition(context: transitionContext)
    }

    frontViewController.didMove(toParent: self)

    Log.debug(.zStack, "Added: \(children)")
  }

  public func addContentView(_ view: UIView, transition: AnyZStackViewControllerAddingTransition?) {

    assert(Thread.isMainThread)

    let viewController = AnonymousViewController(view: view)
    addContentViewController(viewController, transition: transition)

  }

  public func removeLastViewController(transition: AnyZStackViewControllerRemovingTransition?) {

    assert(Thread.isMainThread)

    guard let viewControllerToRemove = stackingViewControllers.last else {
      Log.error(.zStack, "The last view controller was not found to remove")
      return
    }

    removeViewController(viewControllerToRemove, transition: transition)

    viewControllerToRemove.zStackViewControllerContext = nil
  }

  public func reserveWillRemove(viewController: UIViewController) {
    assert(Thread.isMainThread)
    reservedRemovingViewControllers.insert(viewController)
  }

  public func cancelWillRemove(viewController: UIViewController) {
    assert(Thread.isMainThread)
    reservedRemovingViewControllers.remove(viewController)
  }

  public func removeViewController(
    _ viewController: UIViewController,
    transition: AnyZStackViewControllerRemovingTransition?
  ) {

    guard let index = stackingViewControllers.firstIndex(of: viewController) else {
      Log.error(.zStack, "\(viewController) was not found to remove")
      return
    }

    let backViewController: UIViewController? = {
      let target = index.advanced(by: -1)
      if stackingViewControllers.indices.contains(target) {
        return stackingViewControllers[target]
      } else {
        return nil
      }
    }()

    viewController.willMove(toParent: nil)
    viewController.removeFromParent()

    if let transition = transition {

      let context = ZStackViewControllerRemovingTransitionContext(
        contentView: view,
        fromViewController: viewController,
        toViewController: backViewController
      )

      transition.startTransition(context: context)
    } else {
      viewController.view.removeFromSuperview()
    }

    Log.debug(.zStack, "Removed => \(children)")

  }

  public func removeAllViewController(
    from viewController: UIViewController,
    transition: AnyZStackViewControllerBatchRemovingTransition?
  ) {

    Log.debug(.zStack, "Remove \(viewController) from \(stackingViewControllers)")

    assert(Thread.isMainThread)

    guard let index = stackingViewControllers.firstIndex(of: viewController) else {
      Log.error(.zStack, "\(viewController) was not found to remove")
      return
    }

    reservedRemovingViewControllers.remove(viewController)

    let targetTopViewController: UIViewController? = stackingViewControllers[0..<(index)].last

    let viewControllersToRemove = Array(
      stackingViewControllers[
        index...stackingViewControllers.indices.last!
      ]
        .filter {
          reservedRemovingViewControllers.contains($0) == false
        }
    )

    if let transition = transition {

      viewControllersToRemove.forEach {
        $0.willMove(toParent: nil)
        $0.removeFromParent()
      }

      let context = ZStackViewControllerBatchRemovingTransitionContext(
        contentView: view,
        fromViewControllers: viewControllersToRemove,
        toViewController: targetTopViewController
      )

      transition.startTransition(context: context)

    } else {

      while stackingViewControllers.last != targetTopViewController {

        let viewControllerToRemove = stackingViewControllers.last!

        assert(stackingViewControllers.last == viewControllerToRemove)

        viewControllerToRemove.willMove(toParent: nil)
        viewControllerToRemove.view.removeFromSuperview()
        viewControllerToRemove.removeFromParent()

        stackingViewControllers.removeLast()

      }

    }

    Log.debug(.zStack, "Removed => \(children)")

  }

}

public struct ZStackViewControllerContext {

  public private(set) weak var zStackViewController: ZStackViewController?
  public private(set) weak var targetViewController: UIViewController?

  public func addContentViewController(
    _ viewController: UIViewController,
    transition: AnyZStackViewControllerAddingTransition?
  ) {
    zStackViewController?.addContentViewController(viewController, transition: transition)
  }

  public func addContentView(_ view: UIView, transition: AnyZStackViewControllerAddingTransition?) {
    zStackViewController?.addContentView(view, transition: transition)
  }

  public func removeSelf(transition: AnyZStackViewControllerRemovingTransition?) {
    guard let targetViewController = targetViewController else {
      return
    }
    zStackViewController?.removeViewController(targetViewController, transition: transition)
  }

  public func reserveWillRemoveSelf() {
    guard let targetViewController = targetViewController else {
      return
    }
    zStackViewController?.reserveWillRemove(viewController: targetViewController)
  }

  public func cancelWillRemoveSelf() {
    guard let targetViewController = targetViewController else {
      return
    }
    zStackViewController?.cancelWillRemove(viewController: targetViewController)
  }
}

var ref: Void?

extension UIViewController {

  public internal(set) var zStackViewControllerContext: ZStackViewControllerContext? {
    get {

      guard let object = objc_getAssociatedObject(self, &ref) as? ZStackViewControllerContext else {
        return parent?.zStackViewControllerContext
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

private final class AnonymousViewController: UIViewController {

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
