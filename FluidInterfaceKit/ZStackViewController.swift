import UIKit

open class ZStackViewController: UIViewController {

  private struct State: Equatable {

  }

  private var state: State = .init()
  private let __rootView: UIView?

  public var stackingViewControllers: [UIViewController] = []

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

  private var viewControllerStateMap: NSMapTable<UIViewController, ViewControllerStateToken> =
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

  public func addContentViewController(
    _ viewControllerToAdd: UIViewController,
    transition: AnyAddingTransition?
  ) {

    assert(Thread.isMainThread)

//    guard stackingViewControllers.contains(viewControllerToAdd) == false else {
//      Log.error(.zStack, "\(viewControllerToAdd) has been already added in ZStackViewController")
//      return
//    }

    let backViewController = stackingViewControllers.last
    stackingViewControllers.removeAll { $0 == viewControllerToAdd }
    stackingViewControllers.append(viewControllerToAdd)

    /// set context
    viewControllerToAdd.zStackViewControllerContext = .init(
      zStackViewController: self,
      targetViewController: viewControllerToAdd
    )

    let addingToken = ViewControllerStateToken(state: .adding)
    setViewControllerState(viewController: viewControllerToAdd, token: addingToken)

    if viewControllerToAdd.parent != self {
      addChild(viewControllerToAdd)
      view.addSubview(viewControllerToAdd.view)
      viewControllerToAdd.view.frame = self.view.bounds
      viewControllerToAdd.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      viewControllerToAdd.didMove(toParent: self)
    } else {
      if viewControllerToAdd.view.superview == nil {
        view.addSubview(viewControllerToAdd.view)
      }
    }

    lazy var transitionContext = AddingTransitionContext(
      contentView: self.view,
      fromViewController: backViewController,
      toViewController: viewControllerToAdd,
      onCompleted: { [weak self] _ in

        guard let self = self else { return }

        guard self.viewControllerState(viewController: viewControllerToAdd) == addingToken else {
          return
        }

        self.setViewControllerState(viewController: viewControllerToAdd, token: .init(state: .added))

      }
    )

    if let transition = transition {

      transition.startTransition(context: transitionContext)
    } else if let transitionViewController = viewControllerToAdd as? TransitionViewController {

      transitionViewController.startAddingTransition(
        context: transitionContext
      )

    } else {
      setViewControllerState(viewController: viewControllerToAdd, token: .init(state: .added))
    }

    Log.debug(.zStack, "Added: \(children)")
  }

  public func setRemovingState(_ viewControllerToRemove: UIViewController) {

    let removingToken = ViewControllerStateToken(state: .removing)
    setViewControllerState(viewController: viewControllerToRemove, token: removingToken)

  }

  public func removeViewController(
    _ viewControllerToRemove: UIViewController,
    transition: AnyRemovingTransition?
  ) {

    guard let index = stackingViewControllers.firstIndex(of: viewControllerToRemove) else {
      Log.error(.zStack, "\(viewControllerToRemove) was not found to remove")
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

    let removingToken = ViewControllerStateToken(state: .removing)
    setViewControllerState(viewController: viewControllerToRemove, token: removingToken)

    let context = RemovingTransitionContext(
      contentView: view,
      fromViewController: viewControllerToRemove,
      toViewController: backViewController,
      onCompleted: { [weak self] _ in

        guard let self = self else { return }

        guard self.viewControllerState(viewController: viewControllerToRemove) == removingToken else {
          return
        }

        self.setViewControllerState(viewController: viewControllerToRemove, token: .init(state: .removed))

        self.stackingViewControllers.remove(at: index)
        viewControllerToRemove.zStackViewControllerContext = nil

        viewControllerToRemove.willMove(toParent: nil)
        viewControllerToRemove.view.removeFromSuperview()
        viewControllerToRemove.removeFromParent()

      }
    )

    if let transition = transition {

      transition.startTransition(context: context)
    } else if let transitionViewController = viewControllerToRemove as? TransitionViewController {
      transitionViewController.startRemovingTransition(context: context)
    } else {
      viewControllerToRemove.view.removeFromSuperview()
      self.setViewControllerState(viewController: viewControllerToRemove, token: .init(state: .removed))
      self.stackingViewControllers.remove(at: index)
      viewControllerToRemove.zStackViewControllerContext = nil
    }

    Log.debug(.zStack, "Removed => \(children)")

  }

  public func removeAllViewController(
    from viewController: UIViewController,
    transition: AnyBatchRemovingTransition?
  ) {

    Log.debug(.zStack, "Remove \(viewController) from \(stackingViewControllers)")

    assert(Thread.isMainThread)

    guard let index = stackingViewControllers.firstIndex(of: viewController) else {
      Log.error(.zStack, "\(viewController) was not found to remove")
      return
    }

    let targetTopViewController: UIViewController? = stackingViewControllers[0..<(index)].last

    let viewControllersToRemove = Array(
      stackingViewControllers[
        index...stackingViewControllers.indices.last!
      ]
    )

    if let transition = transition {

      viewControllersToRemove.forEach {
        $0.willMove(toParent: nil)
        $0.removeFromParent()
      }

      let context = BatchRemovingTransitionContext(
        contentView: view,
        fromViewControllers: viewControllersToRemove,
        toViewController: targetTopViewController,
        onCompleted: { [weak self] _ in

        }
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

  private func setViewControllerState(viewController: UIViewController, token: ViewControllerStateToken)
  {
    viewControllerStateMap.setObject(token, forKey: viewController)
  }

  private func viewControllerState(viewController: UIViewController) -> ViewControllerStateToken? {
    viewControllerStateMap.object(forKey: viewController)
  }
}

public struct ZStackViewControllerContext {

  public private(set) weak var zStackViewController: ZStackViewController?
  public private(set) weak var targetViewController: UIViewController?

  public func addContentViewController(
    _ viewController: UIViewController,
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

  public func setRemovingState() {
    guard let targetViewController = targetViewController else {
      return
    }
    zStackViewController?.setRemovingState(targetViewController)
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
