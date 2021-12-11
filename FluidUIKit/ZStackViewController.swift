import UIKit

//final class ReentrancyChecker {
//  var count: UInt64 = 0
//
//  func enter() {
//    assert(count == 0)
//    count &+= 1
//  }
//
//  func leave() {
//    count &-= 1
//  }
//}

public final class ZStackViewControllerTransitionContext: Equatable {

  public static func == (lhs: ZStackViewControllerTransitionContext, rhs: ZStackViewControllerTransitionContext) -> Bool {
    lhs === rhs
  }

  public let contentView: UIView
  public let fromViewController: UIViewController?
  public let toViewController: UIViewController?

  private let _notifyTransitionCompleted: () -> Void
  private let _notifyTransitionCancelled: () -> Void

  init(
    contentView: UIView,
    fromViewController: UIViewController?,
    toViewController: UIViewController?,
    onCompleted: @escaping () -> Void,
    onCancelled: @escaping () -> Void
  ) {
    self.contentView = contentView
    self.fromViewController = fromViewController
    self.toViewController = toViewController
    self._notifyTransitionCompleted = onCompleted
    self._notifyTransitionCancelled = onCancelled
  }

  public func notifyTransitionCompleted() {
    _notifyTransitionCompleted()
  }

  public func notifyTransitionCancelled() {
    _notifyTransitionCancelled()
  }
}

public protocol ZStackViewControllerTransitioning {

  func startTransition(context: ZStackViewControllerTransitionContext)

}

public struct AnyZStackViewControllerTransition: ZStackViewControllerTransitioning {

  private let _startTransition: (ZStackViewControllerTransitionContext) -> Void

  public init(
    startTransition: @escaping (ZStackViewControllerTransitionContext) -> Void
  ) {
    self._startTransition = startTransition
  }

  public func startTransition(context: ZStackViewControllerTransitionContext) {
    _startTransition(context)
  }
}

open class ZStackViewController: UIViewController {

  private struct State: Equatable {

    var currentTransition: ZStackViewControllerTransitionContext?
  }

  private var state: State = .init()
  private let __rootView: UIView?

  public var stackingViewControllers: [UIViewController] = []

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
    transition: ZStackViewControllerTransitioning?
  ) {

    assert(Thread.isMainThread)

    guard state.currentTransition == nil else {
      assertionFailure("Current transition is not finished.")
      return
    }

    guard stackingViewControllers.contains(frontViewController) == false else {
      Log.error(.zStack, "\(frontViewController) has been already added in ZStackViewController")
      return
    }

    let backViewController = stackingViewControllers.last
    stackingViewControllers.append(frontViewController)

    if let transition = transition {

      frontViewController.zStackViewControllerContext = .init(zStackViewController: self)

      addChild(frontViewController)

      self.view.addSubview(frontViewController.view)
      frontViewController.view.frame = self.view.bounds
      frontViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

      let transitionContext = ZStackViewControllerTransitionContext(
        contentView: self.view,
        fromViewController: backViewController,
        toViewController: frontViewController,
        onCompleted: { [weak self] in

          guard let self = self else { return }

          self.state.currentTransition = nil

          frontViewController.didMove(toParent: self)
        },
        onCancelled: { [weak self] in

          guard let self = self else { return }

          assert(self.stackingViewControllers.last == frontViewController)

          self.state.currentTransition = nil

          self.stackingViewControllers.removeLast()
          frontViewController.willMove(toParent: nil)
          frontViewController.view.removeFromSuperview()
          frontViewController.removeFromParent()

        }
      )

      state.currentTransition = transitionContext

      transition.startTransition(context: transitionContext)

    } else {

      frontViewController.zStackViewControllerContext = .init(zStackViewController: self)

      addChild(frontViewController)

      self.view.addSubview(frontViewController.view)
      frontViewController.view.frame = self.view.bounds
      frontViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

      frontViewController.didMove(toParent: self)

    }

  }

  public func addContentView(_ view: UIView, transition: ZStackViewControllerTransitioning?) {

    assert(Thread.isMainThread)

    let viewController = AnonymousViewController(view: view)
    addContentViewController(viewController, transition: transition)
  }

  public func removeLastViewController() {

    assert(Thread.isMainThread)

    guard let viewControllerToRemove = stackingViewControllers.last else {
      Log.error(.zStack, "The last view controller was not found to remove")
      return
    }

    viewControllerToRemove.zStackViewControllerContext = nil

    removeViewController(viewControllerToRemove)
  }

  public func removeViewController(_ viewController: UIViewController) {

    assert(Thread.isMainThread)

    guard let index = stackingViewControllers.firstIndex(of: viewController) else {
      Log.error(.zStack, "\(viewController) was not found to remove")
      return
    }

    let viewControllersToRemove = stackingViewControllers[
      index...stackingViewControllers.indices.last!
    ]

    stackingViewControllers = Array(stackingViewControllers[0..<(index)])

    for viewControllerToRemove in viewControllersToRemove {
      viewControllerToRemove.willMove(toParent: nil)
      viewControllerToRemove.view.removeFromSuperview()
      viewControllerToRemove.removeFromParent()
    }

  }

}

public struct ZStackViewControllerContext {

  public private(set) weak var zStackViewController: ZStackViewController?

  public func addContentViewController(
    _ viewController: UIViewController,
    transition: ZStackViewControllerTransitioning?
  ) {
    zStackViewController?.addContentViewController(viewController, transition: transition)
  }

  public func addContentView(_ view: UIView, transition: ZStackViewControllerTransitioning?) {
    zStackViewController?.addContentView(view, transition: transition)
  }

  public func removeSelf() {
    zStackViewController?.removeLastViewController()
  }
}

var ref: Void?

extension UIViewController {

  public internal(set) var zStackViewControllerContext: ZStackViewControllerContext? {
    get {

      guard let object = objc_getAssociatedObject(self, &ref) as? ZStackViewControllerContext else {
        return nil
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
