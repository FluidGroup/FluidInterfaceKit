
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

open class ZStackContainerViewController: UIViewController {

  private let __rootView: UIView?

  public var stackingViewControllers: [UIViewController] = []

  open override func loadView() {
    if let __rootView = __rootView {
      view = __rootView
    } else {
      super.loadView()
    }
  }

  public init(view: UIView? = nil) {
    self.__rootView = view
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func addContentViewController(_ viewController: UIViewController) {

    assert(Thread.isMainThread)

    guard stackingViewControllers.contains(viewController) == false else {
      Log.error(.zStack, "\(viewController) has been already added in ZStackViewController")
      return
    }

//    let backViewController = stackingViewControllers.last

    stackingViewControllers.append(viewController)

    viewController.zStackViewControllerContext = .init(zStackViewController: self)

//    backViewController?.view.removeFromSuperview()

    addChild(viewController)

    self.view.addSubview(viewController.view)
    viewController.view.frame = self.view.bounds
    viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    viewController.didMove(toParent: self)
  }

  public func addContentView(_ view: UIView) {

    assert(Thread.isMainThread)

    let viewController = AnonymousViewController(view: view)
    addContentViewController(viewController)
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

    let viewControllersToRemove = stackingViewControllers[index...stackingViewControllers.indices.last!]

    stackingViewControllers = Array(stackingViewControllers[0..<(index)])

    for viewControllerToRemove in viewControllersToRemove {
      viewControllerToRemove.willMove(toParent: nil)
      viewControllerToRemove.view.removeFromSuperview()
      viewControllerToRemove.removeFromParent()
    }

  }


}

public struct ZStackViewControllerContext {

  public private(set) weak var zStackViewController: ZStackContainerViewController?

  public func addContentViewController(_ viewController: UIViewController) {
    zStackViewController?.addContentViewController(viewController)
  }

  public func addContentView(_ view: UIView) {
    zStackViewController?.addContentView(view)
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

  init(view: UIView) {
    self.__rootView = view
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
