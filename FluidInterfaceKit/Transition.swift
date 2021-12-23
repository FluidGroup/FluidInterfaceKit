import UIKit

public final class AddingTransitionContext: Equatable {

  public static func == (
    lhs: AddingTransitionContext,
    rhs: AddingTransitionContext
  ) -> Bool {
    lhs === rhs
  }

  public private(set) var isCompleted: Bool = false
  public let contentView: UIView
  public let fromViewController: UIViewController?
  public let toViewController: UIViewController
  private let onCompleted: (AddingTransitionContext) -> Void

  init(
    contentView: UIView,
    fromViewController: UIViewController?,
    toViewController: UIViewController,
    onCompleted: @escaping (AddingTransitionContext) -> Void
  ) {
    self.contentView = contentView
    self.fromViewController = fromViewController
    self.toViewController = toViewController
    self.onCompleted = onCompleted
  }

  public func notifyCompleted() {
    isCompleted = true
    onCompleted(self)
  }

}

public final class BatchRemovingTransitionContext: Equatable {

  public static func == (
    lhs: BatchRemovingTransitionContext,
    rhs: BatchRemovingTransitionContext
  ) -> Bool {
    lhs === rhs
  }

  public private(set) var isCompleted: Bool = false
  public let contentView: UIView
  public let fromViewControllers: [UIViewController]
  public let toViewController: UIViewController?
  private let onCompleted: (BatchRemovingTransitionContext) -> Void

  init(
    contentView: UIView,
    fromViewControllers: [UIViewController],
    toViewController: UIViewController?,
    onCompleted: @escaping (BatchRemovingTransitionContext) -> Void
  ) {
    self.contentView = contentView
    self.fromViewControllers = fromViewControllers
    self.toViewController = toViewController
    self.onCompleted = onCompleted
  }

  public func notifyCompleted() {
    isCompleted = true
    onCompleted(self)
  }
}

public final class RemovingTransitionContext: Equatable {

  public static func == (
    lhs: RemovingTransitionContext,
    rhs: RemovingTransitionContext
  ) -> Bool {
    lhs === rhs
  }

  public private(set) var isCompleted: Bool = false

  public let contentView: UIView
  public let fromViewController: UIViewController
  public let toViewController: UIViewController?
  private let onCompleted: (RemovingTransitionContext) -> Void

  init(
    contentView: UIView,
    fromViewController: UIViewController,
    toViewController: UIViewController?,
    onCompleted: @escaping (RemovingTransitionContext) -> Void
  ) {
    self.contentView = contentView
    self.fromViewController = fromViewController
    self.toViewController = toViewController
    self.onCompleted = onCompleted
  }

  public func notifyCompleted() {
    isCompleted = true
    onCompleted(self)
  }
}

public struct TransitionPair {

  public var adding: AnyAddingTransition?
  public var removing: AnyRemovingTransition?

  public init(
    adding: AnyAddingTransition?,
    removing: AnyRemovingTransition?
  ) {
    self.adding = adding
    self.removing = removing
  }

  public static var noTransition: Self {
    return .init(adding: nil, removing: nil)
  }
}

public struct AnyAddingTransition {

  private let _startTransition: (AddingTransitionContext) -> Void

  public init(
    startTransition: @escaping (AddingTransitionContext) -> Void
  ) {
    self._startTransition = startTransition
  }

  public func startTransition(context: AddingTransitionContext) {
    _startTransition(context)
  }
}


public struct AnyRemovingTransition {

  private let _startTransition: (RemovingTransitionContext) -> Void

  public init(
    startTransition: @escaping (RemovingTransitionContext) -> Void
  ) {
    self._startTransition = startTransition
  }

  public func startTransition(context: RemovingTransitionContext) {
    _startTransition(context)
  }
}

public struct AnyBatchRemovingTransition {

  private let _startTransition: (BatchRemovingTransitionContext) -> Void

  public init(
    startTransition: @escaping (BatchRemovingTransitionContext) -> Void
  ) {
    self._startTransition = startTransition
  }

  public func startTransition(context: BatchRemovingTransitionContext) {
    _startTransition(context)
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

func makeTranslation(from: CGRect, to: CGRect) -> (center: CGPoint, transform: CGAffineTransform) {

  return (
    center: to.center,
    transform: .init(
      a: to.width / from.width,
      b: 0,
      c: 0,
      d: to.height / from.height,
      tx: 0,
      ty: 0
    )
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

extension CGRect {
  // MARK: Public

  var center: CGPoint {
    return CGPoint(x: self.midX, y: self.midY)
  }
}
