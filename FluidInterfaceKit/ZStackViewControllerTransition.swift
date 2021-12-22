import UIKit

public final class ZStackViewControllerAddingTransitionContext: Equatable {

  public static func == (
    lhs: ZStackViewControllerAddingTransitionContext,
    rhs: ZStackViewControllerAddingTransitionContext
  ) -> Bool {
    lhs === rhs
  }

  public let contentView: UIView
  public let fromViewController: UIViewController?
  public let toViewController: UIViewController

  init(
    contentView: UIView,
    fromViewController: UIViewController?,
    toViewController: UIViewController
  ) {
    self.contentView = contentView
    self.fromViewController = fromViewController
    self.toViewController = toViewController
  }

}

public final class ZStackViewControllerBatchRemovingTransitionContext: Equatable {

  public static func == (
    lhs: ZStackViewControllerBatchRemovingTransitionContext,
    rhs: ZStackViewControllerBatchRemovingTransitionContext
  ) -> Bool {
    lhs === rhs
  }

  public let contentView: UIView
  public let fromViewControllers: [UIViewController]
  public let toViewController: UIViewController?

  init(
    contentView: UIView,
    fromViewControllers: [UIViewController],
    toViewController: UIViewController?
  ) {
    self.contentView = contentView
    self.fromViewControllers = fromViewControllers
    self.toViewController = toViewController
  }
}

public final class ZStackViewControllerRemovingTransitionContext: Equatable {

  public static func == (
    lhs: ZStackViewControllerRemovingTransitionContext,
    rhs: ZStackViewControllerRemovingTransitionContext
  ) -> Bool {
    lhs === rhs
  }

  public let contentView: UIView
  public let fromViewController: UIViewController
  public let toViewController: UIViewController?

  init(
    contentView: UIView,
    fromViewController: UIViewController,
    toViewController: UIViewController?
  ) {
    self.contentView = contentView
    self.fromViewController = fromViewController
    self.toViewController = toViewController
  }
}

public struct TransitionPair {

  public var adding: AnyZStackViewControllerAddingTransition?
  public var removing: AnyZStackViewControllerRemovingTransition?

  public init(
    adding: AnyZStackViewControllerAddingTransition?,
    removing: AnyZStackViewControllerRemovingTransition?
  ) {
    self.adding = adding
    self.removing = removing
  }

  public static var noTransition: Self {
    return .init(adding: nil, removing: nil)
  }
}

public struct AnyZStackViewControllerAddingTransition {

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

extension AnyZStackViewControllerAddingTransition {

  public static var noAnimation: Self {
    return .init { context in      
    }
  }

  public static func popup(
    duration: TimeInterval = 0.6
  ) -> Self {

    return .init { context in

      context.toViewController.view.transform = .init(scaleX: 0.8, y: 0.8)
      context.toViewController.view.alpha = 0

      let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {

        context.toViewController.view.transform = .identity
        context.toViewController.view.alpha = 1

      }

      animator.addCompletion { _ in
      }

      animator.startAnimation()

    }

  }

  public static func popupContextual(from coordinateSpace: UICoordinateSpace) -> Self {

    return .init { context in

      let frame = coordinateSpace.convert(coordinateSpace.bounds, to: context.contentView)

      let fromFrame = rectThatAspectFit(
        aspectRatio: context.contentView.bounds.size,
        boundingRect: frame
      )

      let t = makeCGAffineTransform(from: context.contentView.bounds, to: fromFrame)

      context.toViewController.view.transform = t
      if #available(iOS 13.0, *) {
        context.toViewController.view.layer.cornerCurve = .continuous
      } else {
        // Fallback on earlier versions
      }
      context.toViewController.view.layer.cornerRadius = 80
      context.toViewController.view.layer.masksToBounds = true

      context.toViewController.view.alpha = 1

      let animator = UIViewPropertyAnimator(duration: 0.6, dampingRatio: 1) {

        context.toViewController.view.transform = .identity
        context.toViewController.view.alpha = 1
        context.toViewController.view.layer.cornerRadius = 0
      }

      animator.addCompletion { _ in
      }

      animator.startAnimation()

    }

  }

}

public struct AnyZStackViewControllerRemovingTransition {

  private let _startTransition: (ZStackViewControllerRemovingTransitionContext) -> Void

  public init(
    startTransition: @escaping (ZStackViewControllerRemovingTransitionContext) -> Void
  ) {
    self._startTransition = startTransition
  }

  public func startTransition(context: ZStackViewControllerRemovingTransitionContext) {
    _startTransition(context)
  }
}

extension AnyZStackViewControllerRemovingTransition {

  public static var noAnimation: Self {
    return .init { context in
      context.fromViewController.view.removeFromSuperview()
    }
  }

  public static func vanishing(duration: TimeInterval = 0.6) -> Self {

    return .init { context in

      let topViewController = context.fromViewController

      let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {

        topViewController.view.alpha = 0

        context.toViewController?.view.transform = .identity
        context.toViewController?.view.alpha = 1

      }

      animator.addCompletion { _ in
        topViewController.view.alpha = 1
        topViewController.view.removeFromSuperview()
      }

      animator.startAnimation()

    }

  }

}

public struct AnyZStackViewControllerBatchRemovingTransition {

  private let _startTransition: (ZStackViewControllerBatchRemovingTransitionContext) -> Void

  public init(
    startTransition: @escaping (ZStackViewControllerBatchRemovingTransitionContext) -> Void
  ) {
    self._startTransition = startTransition
  }

  public func startTransition(context: ZStackViewControllerBatchRemovingTransitionContext) {
    _startTransition(context)
  }
}

extension AnyZStackViewControllerBatchRemovingTransition {

  public static func vanishing(duration: TimeInterval = 0.6) -> Self {

    return .init { context in

      let topViewController = context.fromViewControllers.last!
      let middleViewControllers = context.fromViewControllers.dropLast()

      middleViewControllers.forEach {
        $0.view.isHidden = true
      }

      let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {

        topViewController.view.alpha = 0

        context.toViewController?.view.transform = .identity
        context.toViewController?.view.alpha = 1

      }

      animator.addCompletion { _ in
        topViewController.view.alpha = 1
        middleViewControllers.forEach {
          $0.view.isHidden = false
        }

        context.fromViewControllers.forEach {
          $0.view.removeFromSuperview()
        }
      }

      animator.startAnimation()

    }

  }

}

func makeCGAffineTransform(from: CGRect, to: CGRect) -> CGAffineTransform {

  return .init(
    a: to.width / from.width,
    b: 0,
    c: 0,
    d: to.height / from.height,
    tx: to.midX - from.midX,
    ty: to.midY - from.midY
  )
}

/// From Brightroom
func sizeThatAspectFit(aspectRatio: CGSize, boundingSize: CGSize) -> CGSize {
  let widthRatio = boundingSize.width / aspectRatio.width
  let heightRatio = boundingSize.height / aspectRatio.height
  var size = boundingSize

  if widthRatio < heightRatio {
    size.height = boundingSize.width / aspectRatio.width * aspectRatio.height
  } else if heightRatio < widthRatio {
    size.width = boundingSize.height / aspectRatio.height * aspectRatio.width
  }

  return CGSize(
    width: ceil(size.width),
    height: ceil(size.height)
  )
}

/// From Brightroom
func rectThatAspectFit(aspectRatio: CGSize, boundingRect: CGRect) -> CGRect {
  let size = sizeThatAspectFit(aspectRatio: aspectRatio, boundingSize: boundingRect.size)
  var origin = boundingRect.origin
  origin.x += (boundingRect.size.width - size.width) / 2.0
  origin.y += (boundingRect.size.height - size.height) / 2.0
  return CGRect(origin: origin, size: size)
}
