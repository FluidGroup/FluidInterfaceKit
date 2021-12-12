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

public final class ZStackViewControllerAddingTransitionContext: Equatable {

  public static func == (lhs: ZStackViewControllerAddingTransitionContext, rhs: ZStackViewControllerAddingTransitionContext) -> Bool {
    lhs === rhs
  }

  public let contentView: UIView
  public let fromViewController: UIViewController?
  public let toViewController: UIViewController

  private let _notifyTransitionCompleted: () -> Void
  private let _notifyTransitionCancelled: () -> Void

  init(
    contentView: UIView,
    fromViewController: UIViewController?,
    toViewController: UIViewController,
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

public final class ZStackViewControllerRemovingTransitionContext: Equatable {

  public static func == (lhs: ZStackViewControllerRemovingTransitionContext, rhs: ZStackViewControllerRemovingTransitionContext) -> Bool {
    lhs === rhs
  }

  public let contentView: UIView
  public let fromViewControllers: [UIViewController]
  public let toViewController: UIViewController?

  private let _notifyTransitionCompleted: () -> Void
  private let _notifyTransitionCancelled: () -> Void

  init(
    contentView: UIView,
    fromViewControllers: [UIViewController],
    toViewController: UIViewController?,
    onCompleted: @escaping () -> Void,
    onCancelled: @escaping () -> Void
  ) {
    self.contentView = contentView
    self.fromViewControllers = fromViewControllers
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

public protocol ZStackViewControllerAddingTransitioning {

  func startTransition(context: ZStackViewControllerAddingTransitionContext)

}

public protocol ZStackViewControllerRemovingTransitioning {

  func startTransition(context: ZStackViewControllerRemovingTransitionContext)

}

public struct AnyZStackViewControllerTransition: ZStackViewControllerAddingTransitioning {

  private let _startTransition: (ZStackViewControllerAddingTransitionContext) -> Void

  public init(
    startTransition: @escaping (ZStackViewControllerAddingTransitionContext) -> Void
  ) {
    self._startTransition = startTransition
  }

  public func startTransition(context: ZStackViewControllerAddingTransitionContext) {
    _startTransition(context)
  }
}

extension AnyZStackViewControllerTransition {

  public static func popup() -> Self {

    return .init { context in

      context.toViewController.view.transform = .init(scaleX: 0.8, y: 0.8)
      context.toViewController.view.alpha = 0

      let animator = UIViewPropertyAnimator(duration: 0.6, dampingRatio: 1) {

        context.toViewController.view.transform = .identity
        context.toViewController.view.alpha = 1

      }

      animator.addCompletion { _ in
        context.notifyTransitionCompleted()
      }

      animator.startAnimation()

    }

  }

}

open class ZStackViewController: UIViewController {

  private struct State: Equatable {

    var currentTransition: ZStackViewControllerAddingTransitionContext?
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
    transition: AnyZStackViewControllerTransition?
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

    /// set context
    frontViewController.zStackViewControllerContext = .init(zStackViewController: self)

    if let transition = transition {

      addChild(frontViewController)

      self.view.addSubview(frontViewController.view)
      frontViewController.view.frame = self.view.bounds
      frontViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

      let transitionContext = ZStackViewControllerAddingTransitionContext(
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

      addChild(frontViewController)

      self.view.addSubview(frontViewController.view)
      frontViewController.view.frame = self.view.bounds
      frontViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

      frontViewController.didMove(toParent: self)

    }

  }

  public func addContentView(_ view: UIView, transition: AnyZStackViewControllerTransition?) {

    assert(Thread.isMainThread)

    let viewController = AnonymousViewController(view: view)
    addContentViewController(viewController, transition: transition)
  }

  public func removeLastViewController(transition: ZStackViewControllerRemovingTransitioning?) {

    assert(Thread.isMainThread)

    guard let viewControllerToRemove = stackingViewControllers.last else {
      Log.error(.zStack, "The last view controller was not found to remove")
      return
    }

    removeViewController(viewControllerToRemove, transitionProvider: { _ in transition })

    viewControllerToRemove.zStackViewControllerContext = nil
  }

  public func removeViewController(
    _ viewController: UIViewController,
    transitionProvider: (UIViewController) -> ZStackViewControllerRemovingTransitioning?
  ) {

    assert(Thread.isMainThread)

    guard let index = stackingViewControllers.firstIndex(of: viewController) else {
      Log.error(.zStack, "\(viewController) was not found to remove")
      return
    }

    let targetTopViewController: UIViewController? = stackingViewControllers[0..<(index)].last

    let viewControllersToRemove = Array(stackingViewControllers[
      index...stackingViewControllers.indices.last!
    ])

    let previousStack = stackingViewControllers

    ZStackViewControllerRemovingTransitionContext(
      contentView: view,
      fromViewControllers: viewControllersToRemove,
      toViewController: targetTopViewController,
      onCompleted: {

      },
      onCancelled: {

      })

    while(stackingViewControllers.last != targetTopViewController) {

      let viewControllerToRemove = stackingViewControllers.last!

      /*
      if let transition = transitionProvider(viewControllerToRemove) {

        let index = previousStack.firstIndex(of: viewControllerToRemove)!
        let toViewController: UIViewController? = {
          let targetIndex = index.advanced(by: -1)
          if previousStack.indices.contains(targetIndex) {
            return previousStack[targetIndex]
          }
          return nil
        }()

        var isTransitioning = true
        var breaks = false

        let transitionContext = ZStackViewControllerAddingTransitionContext(
          contentView: self.view,
          fromViewController: viewControllerToRemove,
          toViewController: toViewController,
          onCompleted: { [weak self] in

            guard let self = self else { return }

            self.state.currentTransition = nil

            viewControllerToRemove.willMove(toParent: nil)
            viewControllerToRemove.view.removeFromSuperview()
            viewControllerToRemove.removeFromParent()

            isTransitioning = false
          },
          onCancelled: { [weak self] in

            guard let self = self else { return }

            self.state.currentTransition = nil

            breaks = true
            isTransitioning = false
          }
        )

        state.currentTransition = transitionContext
//        transition.startTransition(context: transitionContext)

        while(isTransitioning) {
          RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.001))
        }

        if breaks {
          break
        }

      } else {

       */
        assert(stackingViewControllers.last == viewControllerToRemove)

        viewControllerToRemove.willMove(toParent: nil)
        viewControllerToRemove.view.removeFromSuperview()
        viewControllerToRemove.removeFromParent()

        stackingViewControllers.removeLast()

//      }
    }


  }

}

public struct ZStackViewControllerContext {

  public private(set) weak var zStackViewController: ZStackViewController?

  public func addContentViewController(
    _ viewController: UIViewController,
    transition: AnyZStackViewControllerTransition?
  ) {
    zStackViewController?.addContentViewController(viewController, transition: transition)
  }

  public func addContentView(_ view: UIView, transition: AnyZStackViewControllerTransition?) {
    zStackViewController?.addContentView(view, transition: transition)
  }

  public func removeSelf(transition: ZStackViewControllerRemovingTransitioning?) {
    zStackViewController?.removeLastViewController(transition: transition)
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
