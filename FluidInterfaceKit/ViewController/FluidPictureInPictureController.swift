import UIKit
import GeometryKit

open class FluidPictureInPictureController: UIViewController {


  private struct Position: OptionSet {
    let rawValue: Int

    static let right: Position = .init(rawValue: 1 << 0)
    static let left: Position = .init(rawValue: 1 << 1)
    static let top: Position = .init(rawValue: 1 << 2)
    static let bottom: Position = .init(rawValue: 1 << 3)

    init(rawValue: Int) {
      self.rawValue = rawValue
    }
  }

  private var customView: View {
    view as! View
  }

  open override func loadView() {
    view = View()
  }

  private var containerView: ContainerView?

  public init() {
    super.init(nibName: nil, bundle: nil)

  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open override func viewDidLoad() {
    super.viewDidLoad()

  }

}

extension FluidPictureInPictureController {

  public final class ContainerView: UIView {

  }

  private final class View: UIView {

    let containerView: ContainerView = .init()

    private var snappingPosition: Position = [.right, .bottom]

    override init(frame: CGRect) {
      super.init(frame: frame)

      let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))

      containerView.addGestureRecognizer(dragGesture)

      #if DEBUG
      containerView.frame.size = .init(width: 100, height: 100)
      containerView.backgroundColor = .systemYellow
      #endif

      addSubview(containerView)
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
      super.layoutSubviews()

      containerView.frame = calculateFrame(for: snappingPosition)

    }

    override func layoutMarginsDidChange() {
      super.layoutMarginsDidChange()
      setNeedsLayout()
    }

    override func safeAreaInsetsDidChange() {
      super.safeAreaInsetsDidChange()
      setNeedsLayout()
    }

    private func calculateFrame(
      for snappingPositon: Position
    ) -> CGRect {

      let containerBounds = containerView.bounds
      let baseFrame = bounds

      let insetFrame = baseFrame
        .inset(by: safeAreaInsets)
        .insetBy(dx: 12, dy: 12)

      var origin = CGPoint(x: 0, y: 0)

      if snappingPosition.contains(.top) {
        origin.y = insetFrame.minY
      }

      if snappingPosition.contains(.bottom) {
        origin.y = insetFrame.maxY - containerBounds.height
      }

      if snappingPosition.contains(.left) {
        origin.x = insetFrame.minX
      }

      if snappingPosition.contains(.right) {
        origin.x = insetFrame.maxX - containerBounds.width
      }

      return .init(origin: origin, size: containerBounds.size)

    }

    @objc
    private dynamic func handlePanGesture(gesture: UIPanGestureRecognizer) {
      switch gesture.state {
      case .began:
        break
      case .changed:
        let translation = gesture.translation(in: gesture.view)

        let animator = UIViewPropertyAnimator(
          duration: 0.4,
          timingParameters: UISpringTimingParameters(
            dampingRatio: 1,
            initialVelocity: .zero
          )
        )

        animator.addAnimations {
          gesture.view.unsafelyUnwrapped.center.x += translation.x
          gesture.view.unsafelyUnwrapped.center.y += translation.y
        }

        animator.startAnimation()

        gesture.setTranslation(.zero, in: gesture.view)


      case .possible:
        break
      case .ended,
          .cancelled,
          .failed:

        let frame = gesture.view!.convert(gesture.view!.bounds, to: self)
        let gestureVelocity = gesture.velocity(in: self)

        var locationBasedAnchorPoint: Position {
          switch (bounds.width / 2 > frame.minX, bounds.height / 2 > frame.midY) {
          case (true, true):
            return [.left, .top]
          case (true, false):
            return [.left, .bottom]
          case (false, true):
            return [.right, .top]
          case (false, false):
            return [.right, .bottom]
          }
        }

        var flickDirection: Position? {
          let bound: CGFloat = 500

          var directions: Position = []

          switch gestureVelocity.x {
          case ..<(-bound):
            directions.insert(.left)
          case bound...:
            directions.insert(.right)
          default: break
          }

          switch gestureVelocity.y {
          case ..<(-bound):
            directions.insert(.top)
          case bound...:
            directions.insert(.bottom)
          default: break
          }

          return directions
        }

        var velocityBasedAnchorPoint: Position? {
          guard let flickDirection = flickDirection else { return nil }
          var base = locationBasedAnchorPoint

          if flickDirection.contains(.top) {
            base.remove(.bottom)
            base.insert(.top)
          }

          if flickDirection.contains(.bottom) {
            base.remove(.top)
            base.insert(.bottom)
          }

          if flickDirection.contains(.right) {
            base.remove(.left)
            base.insert(.right)
          }

          if flickDirection.contains(.left) {
            base.remove(.right)
            base.insert(.left)
          }

          return base
        }

        snappingPosition = velocityBasedAnchorPoint ?? locationBasedAnchorPoint

        let fromCenter = Geometry.center(of: frame)
        let toCenter = Geometry.center(of: calculateFrame(for: snappingPosition))

        let delta = CGPoint(
          x: toCenter.x - fromCenter.x,
          y: toCenter.y - fromCenter.y
        )

        var baseVelocity = CGVector(
          dx: gestureVelocity.x / delta.x,
          dy: gestureVelocity.y / delta.y
        )

        baseVelocity.dx = baseVelocity.dx.isFinite ? baseVelocity.dx : 0
        baseVelocity.dy = baseVelocity.dy.isFinite ? baseVelocity.dy : 0

        let animator = UIViewPropertyAnimator(
          duration: 0.8,
          timingParameters: UISpringTimingParameters(
            dampingRatio: 0.8,
            initialVelocity: baseVelocity
          )
        )

        animator.addAnimations {
          self.containerView.center = toCenter
        }

        animator.startAnimation()

      @unknown default:
        assertionFailure()
      }
    }
  }

}
