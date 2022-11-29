import GeometryKit
import UIKit

/**
 A container view controller that manages a view to be floating, maximizing, hiding, etc.
 */
open class FluidPictureInPictureController: FluidWrapperViewController {

  public final var state: State {
    customView.state
  }

  private var customView: View {
    view as! View
  }

  public final override func loadView() {
    view = View()
  }
 
  open override func viewDidLoad() {
    super.viewDidLoad()
  }

  public final func setContent(_ content: UIView) {
    customView.containerView.setContent(content)
  }

  public final func setMode(_ mode: Mode, animated: Bool = true) {
    customView.setMode(mode, animated: animated)
  }

}

extension FluidPictureInPictureController {

  struct Position: OptionSet {
    let rawValue: Int

    static let right: Position = .init(rawValue: 1 << 0)
    static let left: Position = .init(rawValue: 1 << 1)
    static let top: Position = .init(rawValue: 1 << 2)
    static let bottom: Position = .init(rawValue: 1 << 3)

    init(
      rawValue: Int
    ) {
      self.rawValue = rawValue
    }
  }

  public enum Mode {
    case maximizing
    case folding
    case floating
    case hiding
  }

  public struct Configuration {

  }

  public final class ContainerView: UIView {
    
    weak var content: UIView?

    /**
      Displays a given view, and the current displaying view would be removed instead.
    */
    public func setContent(_ content: UIView) {
      self.content?.removeFromSuperview()
      addSubview(content)
      self.content = content
      content.frame = bounds
      content.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    public override func action(for layer: CALayer, forKey event: String) -> CAAction? {
      let action = super.action(for: layer, forKey: event)
      Log.debug(.pip, "action for \(layer), key: \(event), action: \(action as Any)")
      return action
    }
  }

  public struct State {

    struct ConditionToLayout: Equatable {
      var bounds: CGRect
      var inset: UIEdgeInsets
      var safeAreaInsets: UIEdgeInsets
      var layoutMargins: UIEdgeInsets
    }

    public internal(set) var mode: Mode = .floating
    var conditionToLayout: ConditionToLayout?
    
    var inset: UIEdgeInsets = .zero
    var snappingPosition: Position = [.right, .bottom]
  }

  private final class View: UIView {

    let containerView: ContainerView = .init()

    let sizeForFloating = CGSize(width: 100, height: 140)
        
    private(set) var state: State = .init() {
      didSet {
        receiveUpdate(state: state, oldState: oldValue)
      }
    }

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
      let view = super.hitTest(point, with: event)
      if view == self {
        return nil
      } else {
        return view
      }
    }

    override init(
      frame: CGRect
    ) {
      super.init(frame: frame)

      let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))

      containerView.addGestureRecognizer(dragGesture)

      addSubview(containerView)
  
      NotificationCenter.default.addObserver(self, selector: #selector(handleInsetsUpdate), name: SafeAreaFinder.notificationName, object: nil)
    }

    required init?(
      coder: NSCoder
    ) {
      fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
      NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleInsetsUpdate(notification: Notification) {
      let inset = notification.object as! UIEdgeInsets
      state.inset = inset
      setNeedsLayout()
      UIViewPropertyAnimator(duration: 0.6, dampingRatio: 1) { [self] in
        self.layoutIfNeeded()
      }
      .startAnimation()
    }

    func setMode(_ mode: Mode, animated: Bool) {
      state.mode = mode
      setNeedsLayout()

      switch mode {
      case .maximizing:
        setIsHidden(false, animated: animated)
      case .folding:
        setIsHidden(false, animated: animated)
      case .floating:
        setIsHidden(false, animated: animated)
      case .hiding:
        setIsHidden(true, animated: animated)
      }

      if animated {

        let animator = UIViewPropertyAnimator(
          duration: 0.6,
          timingParameters: UISpringTimingParameters(
            dampingRatio: 0.9,
            initialVelocity: .zero
          )
        )

        animator.addAnimations {
          self.layoutIfNeeded()
        }

        animator.startAnimation()

      } else {

        layoutIfNeeded()

      }

    }

    override func layoutSubviews() {
      super.layoutSubviews()

      switch state.mode {
      case .hiding:
        break
      case .maximizing:
        containerView.frame = bounds
        state.conditionToLayout = nil
      case .folding:
        break
      case .floating:
        let proposedCondition = State.ConditionToLayout(
          bounds: bounds,
          inset: state.inset,
          safeAreaInsets: safeAreaInsets,
          layoutMargins: layoutMargins
        )

        switch state.conditionToLayout {
        case .some(let condition) where condition != proposedCondition:
          state.conditionToLayout = proposedCondition
        case .none:
          state.conditionToLayout = proposedCondition
        default:
          
          return
        }

        Fluid.setFrameAsIdentity(calculateFrameForFloating(for: state), for: containerView)
      }

    }
    
    override func didMoveToWindow() {
      super.didMoveToWindow()
      
      if window != nil {
        SafeAreaFinder.shared.start()
      } else {
        SafeAreaFinder.shared.pause()
      }
    }
    
    override func layoutMarginsDidChange() {
      super.layoutMarginsDidChange()
      setNeedsLayout()
    }

    override func safeAreaInsetsDidChange() {
      super.safeAreaInsetsDidChange()
      setNeedsLayout()
    }

    private func receiveUpdate(state: State, oldState: State) {

    }

    private func calculateFrameForFloating(
      for state: State
    ) -> CGRect {

      let containerSize = sizeForFloating
      let baseFrame = bounds

      let insetFrame =
        baseFrame
        .inset(by: state.inset)
        .insetBy(dx: 12, dy: 12)

      var origin = CGPoint(x: 0, y: 0)

      if state.snappingPosition.contains(.top) {
        origin.y = insetFrame.minY
      }

      if state.snappingPosition.contains(.bottom) {
        origin.y = insetFrame.maxY - containerSize.height
      }

      if state.snappingPosition.contains(.left) {
        origin.x = insetFrame.minX
      }

      if state.snappingPosition.contains(.right) {
        origin.x = insetFrame.maxX - containerSize.width
      }

      return .init(origin: origin, size: containerSize)

    }

    func setIsHidden(_ isHidden: Bool, animated: Bool) {

      let animator = UIViewPropertyAnimator(duration: 0.6, dampingRatio: 0.8) { [self] in

        if isHidden {
          containerView.alpha = 0
          containerView.transform = .init(scaleX: 0.8, y: 0.8)
//          containerView.blurLayer.blurRadius = 80
//          containerView.blurLayer.makeBlurAction(from: 0).map { action in
//            containerView.blurLayer.add(action, forKey: "blurRadius")
//          }
        } else {
          containerView.alpha = 1
          containerView.transform = .identity
//          containerView.blurLayer.blurRadius = 0
        }
      }

      animator.startAnimation()

      containerView.layer.dumpAllAnimations()

    }

    @objc
    private dynamic func handlePanGesture(gesture: UIPanGestureRecognizer) {

      guard state.mode == .floating else {
        return
      }

      switch gesture.state {
      case .began:
        fallthrough
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

        state.snappingPosition = velocityBasedAnchorPoint ?? locationBasedAnchorPoint

        let fromCenter = Geometry.center(of: frame)
        let toCenter = Geometry.center(of: calculateFrameForFloating(for: state))

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
