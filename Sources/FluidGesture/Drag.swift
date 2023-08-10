import UIKit

extension UIView {

  public func makeDraggable(
    coordinator usingCoordinator: DragCoordinator? = nil,
    descriptor: DragDescriptor
  ) {

    let coordinator = usingCoordinator ?? .init()

    self.addGestureRecognizer(coordinator.gesture)

    let _setOffset: (CGSize, CGVector) -> Void = { targetOffset, velocity in
      let distance = CGSize(
        width: targetOffset.width - coordinator.currentOffset.width,
        height: targetOffset.height - coordinator.currentOffset.height
      )

      coordinator.currentOffset = targetOffset

      var mappedVelocity = CGVector(
        dx: velocity.dx / distance.width,
        dy: velocity.dy / distance.height
      )

      mappedVelocity.formFinited()

      let parameter = descriptor.springParameter

      let animator = UIViewPropertyAnimator(
        duration: 0,
        timingParameters: UISpringTimingParameters(
          mass: parameter.mass,
          stiffness: parameter.stiffness,
          damping: parameter.damping,
          initialVelocity: mappedVelocity
        )
      )

      animator.addAnimations {
        self.layer.position = .init(
          x: coordinator.originalPoint.x + coordinator.currentOffset.width,
          y: coordinator.originalPoint.y + coordinator.currentOffset.height
        )
      }

      animator.startAnimation()
    }

    coordinator.onSetOffset = { newOffset, velocity in
      _setOffset(newOffset, velocity)
    }

    coordinator.gesture.onEvent { [weak self] gesture in

      guard let self = self else { return }

      switch gesture.state {
      case .possible:
        break
      case .began:

        descriptor.handler.onStartDragging()
        coordinator.transactionOffset = coordinator.currentOffset
        coordinator.originalPoint = self.layer.position.applying(
          .init(
            translationX: -coordinator.currentOffset.width,
            y: -coordinator.currentOffset.height
          )
        )

        fallthrough
      case .changed:

        if let vertical = descriptor.vertical {
          let proposed = gesture.translation(in: nil).y + coordinator.transactionOffset.height

          coordinator.currentOffset.height = rubberBand(
            value: proposed,
            min: vertical.min,
            max: vertical.max,
            bandLength: vertical.bandLength
          )
        }

        if let horizontal = descriptor.horizontal {

          let proposed = gesture.translation(in: nil).x + coordinator.transactionOffset.width

          coordinator.currentOffset.width = rubberBand(
            value: proposed,
            min: horizontal.min,
            max: horizontal.max,
            bandLength: horizontal.bandLength
          )
        }

        let draggingAnimator = UIViewPropertyAnimator(duration: 0.1, dampingRatio: 1)

        draggingAnimator.addAnimations {
          self.layer.position = .init(
            x: coordinator.originalPoint.x + coordinator.currentOffset.width,
            y: coordinator.originalPoint.y + coordinator.currentOffset.height
          )
        }
        draggingAnimator.startAnimation()

      case .failed, .cancelled, .ended:

        let rawVelocity = gesture.velocity(in: nil)
        var velocity = CGVector(dx: rawVelocity.x, dy: rawVelocity.y)

        let targetOffset: CGSize = descriptor.handler.onEndDragging(
          &velocity,
          coordinator.currentOffset,
          self.frame.size
        )

        _setOffset(targetOffset, velocity)

        break
      @unknown default:
        break
      }

    }

  }

}

@MainActor
public final class DragCoordinator: NSObject, UIGestureRecognizerDelegate {

  public let gesture: UIPanGestureRecognizer = .init()

  internal var originalPoint: CGPoint = .zero
  internal var currentOffset: CGSize = .zero
  internal var transactionOffset: CGSize = .zero

  internal var onSetOffset: (CGSize, CGVector) -> Void = { _, _ in assertionFailure("not set yet") }

  private var _gestureRecognizerShouldBegin: (@MainActor (_ gesture: UIPanGestureRecognizer) -> Bool)?
  private var _gestureRecognizerShouldRequireFailureOf: (@MainActor (_ gesture: UIPanGestureRecognizer, _ otherGesture: UIGestureRecognizer) -> Bool)?
  private var _gestureRecognizerShouldRecognizeSimultaneouslyWith: (@MainActor (_ gesture: UIPanGestureRecognizer, _ otherGesture: UIGestureRecognizer) -> Bool)?
  private var _gestureRecognizershouldBeRequiredToFailBy: (@MainActor (_ gesture: UIPanGestureRecognizer, _ otherGesture: UIGestureRecognizer) -> Bool)?

  public override init() {
    super.init()
    gesture.delegate = self
  }

  public func invalidate() {
    gesture.view?.removeGestureRecognizer(gesture)
  }

  public func set(offset: CGSize, velocity: CGVector = .zero) {
    onSetOffset(offset, velocity)
  }

  public func setGestureShouldBeginHandler(
    _ handler: @escaping @MainActor (UIPanGestureRecognizer) -> Bool
  ) {
    _gestureRecognizerShouldBegin = handler
  }

  public func setGestureShouldRequireFailureHandler(
    _ handler: @escaping @MainActor (_ gesture: UIPanGestureRecognizer, _ otherGesture: UIGestureRecognizer) -> Bool
  ) {
    _gestureRecognizerShouldRequireFailureOf = handler
  }

  public func setGestureShouldRecognizeSimultaneouslyHandler(
    _ handler: @escaping @MainActor (_ gesture: UIPanGestureRecognizer, _ otherGesture: UIGestureRecognizer) -> Bool
  ) {
    _gestureRecognizerShouldRecognizeSimultaneouslyWith = handler
  }

  public func setGestureShouldBeRequiredToFailHandler(
    _ handler: @escaping @MainActor (_ gesture: UIPanGestureRecognizer, _ otherGesture: UIGestureRecognizer) -> Bool
  ) {
    _gestureRecognizershouldBeRequiredToFailBy = handler
  }

  @_spi(Internal)
  @objc
  public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    _gestureRecognizerShouldBegin?(gestureRecognizer as! UIPanGestureRecognizer) ?? true
  }

  @_spi(Internal)
  @objc
  public func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer
  ) -> Bool {
    _gestureRecognizerShouldRequireFailureOf?(gestureRecognizer as! UIPanGestureRecognizer, otherGestureRecognizer) ?? false
  }

  @_spi(Internal)
  @objc
  public func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
  ) -> Bool {
    _gestureRecognizerShouldRecognizeSimultaneouslyWith?(gestureRecognizer as! UIPanGestureRecognizer, otherGestureRecognizer) ?? false
  }

  @_spi(Internal)
  @objc
  public func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer
  ) -> Bool {
    _gestureRecognizershouldBeRequiredToFailBy?(gestureRecognizer as! UIPanGestureRecognizer, otherGestureRecognizer) ?? false
  }

}

public struct DragDescriptor {

  public struct SpringParameter {

    public let mass: CGFloat
    public let stiffness: CGFloat
    public let damping: CGFloat

    public static var `default`: Self {
      return .init(mass: 1, stiffness: 200, damping: 20)
    }

    public init(
      mass: CGFloat,
      stiffness: CGFloat,
      damping: CGFloat
    ) {
      self.mass = mass
      self.stiffness = stiffness
      self.damping = damping
    }

  }

  public struct Handler {
    /**
     A callback closure that is called when the user finishes dragging the content.
     This closure takes a CGSize as a return value, which is used as the target offset to finalize the animation.

     For example, return CGSize.zero to put it back to the original position.
     */
    public var onEndDragging:
      @MainActor (_ velocity: inout CGVector, _ offset: CGSize, _ contentSize: CGSize) -> CGSize

    public var onStartDragging: @MainActor () -> Void

    public init(
      onStartDragging: @escaping @MainActor () -> Void = {},
      onEndDragging: @escaping @MainActor (
        _ velocity: inout CGVector, _ offset: CGSize, _ contentSize: CGSize
      )
        -> CGSize = { _, _, _ in .zero }
    ) {
      self.onStartDragging = onStartDragging
      self.onEndDragging = onEndDragging
    }
  }

  public struct Boundary {
    public let min: Double
    public let max: Double
    public let bandLength: Double

    public init(min: Double, max: Double, bandLength: Double) {
      self.min = min
      self.max = max
      self.bandLength = bandLength
    }

    public static var infinity: Self {
      return .init(
        min: -Double.greatestFiniteMagnitude,
        max: Double.greatestFiniteMagnitude,
        bandLength: 0
      )
    }
  }

  public let springParameter: SpringParameter
  public let horizontal: Boundary?
  public let vertical: Boundary?
  public let handler: Handler

  public init(
    springParameter: SpringParameter = .default,
    horizontal: Boundary?,
    vertical: Boundary?,
    handler: Handler
  ) {

    self.springParameter = springParameter
    self.horizontal = horizontal
    self.vertical = vertical
    self.handler = handler

  }

}

private func rubberBand(value: CGFloat, min: CGFloat, max: CGFloat, bandLength: CGFloat) -> CGFloat
{
  if value >= min && value <= max {
    // While we're within range we don't rubber band the value.
    return value
  }

  if bandLength <= 0 {
    // The rubber band doesn't exist, return the minimum value so that we stay put.
    return min
  }

  let rubberBandCoefficient: CGFloat = 0.55
  // Accepts values from [0...+inf and ensures that f(x) < bandLength for all values.
  let band: (CGFloat) -> CGFloat = { value in
    let demoninator = value * rubberBandCoefficient / bandLength + 1
    return bandLength * (1 - 1 / demoninator)
  }
  if value > max {
    return band(value - max) + max

  } else if value < min {
    return min - band(min - value)
  }

  return value
}

private var ref: Void?

extension UIPanGestureRecognizer {

  /// [Local extension]
  ///
  @discardableResult
  func onEvent(_ closure: @escaping @MainActor (Self) -> Void) -> Self {

    self.addTarget(self, action: #selector(_target_onEvent))
    _onEvent = { gesture in
      closure(gesture as! Self)
    }

    return self
  }

  fileprivate var _onEvent: (@MainActor (UIGestureRecognizer) -> Void)? {
    get {
      objc_getAssociatedObject(self, &ref) as? (@MainActor (UIGestureRecognizer) -> Void)
    }
    set {
      objc_setAssociatedObject(self, &ref, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  @MainActor
  @objc fileprivate func _target_onEvent(gesture: UIGestureRecognizer) {
    _onEvent?(gesture)
  }

}
