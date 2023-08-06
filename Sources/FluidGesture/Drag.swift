import UIKit

extension UIView {

  @discardableResult
  public func makeDraggable(
    descriptor: DragDescriptor
  ) -> UIPanGestureRecognizer {

    let gesture = UIPanGestureRecognizer()

    self.addGestureRecognizer(gesture)

    var originalPoint: CGPoint = .zero
    var currentOffset: CGSize = .zero
    var transactionOffset: CGSize = .zero

    gesture.onEvent { [weak self] gesture in

      guard let self = self else { return }

      switch gesture.state {
      case .possible:
        break
      case .began:

        descriptor.handler.onStartDragging()
        transactionOffset = currentOffset
        originalPoint = self.layer.position.applying(.init(translationX: -currentOffset.width, y: -currentOffset.height))

        fallthrough
      case .changed:

        if let vertical = descriptor.vertical {
          let proposed = gesture.translation(in: nil).y + transactionOffset.height

          currentOffset.height = rubberBand(
            value: proposed,
            min: vertical.min,
            max: vertical.max,
            bandLength: vertical.bandLength
          )
        }

        if let horizontal = descriptor.horizontal {

          let proposed = gesture.translation(in: nil).x + transactionOffset.width
        

          currentOffset.width = rubberBand(
            value: proposed,
            min: horizontal.min,
            max: horizontal.max,
            bandLength: horizontal.bandLength
          )
        }

        let draggingAnimator = UIViewPropertyAnimator(duration: 0.1, dampingRatio: 1)

        draggingAnimator.addAnimations {
          self.layer.position = .init(
            x: originalPoint.x + currentOffset.width,
            y: originalPoint.y + currentOffset.height
          )
        }
        draggingAnimator.startAnimation()

      case .failed, .cancelled, .ended:

        let rawVelocity = gesture.velocity(in: nil)
        var velocity = CGVector(dx: rawVelocity.x, dy: rawVelocity.y)

        let targetOffset: CGSize = descriptor.handler.onEndDragging(
          &velocity,
          currentOffset,
          self.frame.size
        )

        let distance = CGSize(
          width: targetOffset.width - currentOffset.width,
          height: targetOffset.height - currentOffset.height
        )

        currentOffset = targetOffset

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
            x: originalPoint.x + currentOffset.width,
            y: originalPoint.y + currentOffset.height
          )
        }

        animator.startAnimation()

        break
      @unknown default:
        break
      }

    }

    return gesture

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
      onEndDragging: @escaping @MainActor (_ velocity: inout CGVector, _ offset: CGSize, _ contentSize: CGSize)
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

fileprivate func rubberBand(value: CGFloat, min: CGFloat, max: CGFloat, bandLength: CGFloat) -> CGFloat {
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
