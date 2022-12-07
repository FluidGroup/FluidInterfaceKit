import UIKit

open class FluidSpaceViewController: UIViewController, UIGestureRecognizerDelegate {

  @MainActor
  private final class ViewControllerManager {

    let viewController: UIViewController

    private var isRegisteredAsChildViewController = false

    init(viewController: UIViewController) {
      self.viewController = viewController
    }

    func register(parent: UIViewController) {
      guard isRegisteredAsChildViewController == false else { return }
      isRegisteredAsChildViewController = true
      parent.addChild(viewController)
      viewController.didMove(toParent: parent)
    }

    func display(in view: UIView) {

      let vcView = viewController.view!

      guard vcView.superview != view else { return }

      view.addSubview(vcView)

      vcView.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        vcView.topAnchor.constraint(equalTo: view.topAnchor),
        vcView.rightAnchor.constraint(equalTo: view.rightAnchor),
        vcView.leftAnchor.constraint(equalTo: view.leftAnchor),
        vcView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      ])
    }

    func preload() {

      viewController.loadViewIfNeeded()

    }

  }

  private let managedItems: [ViewControllerManager]
  private var currentIndex: Int = 1

  public init(
    viewControllers: [UIViewController]
  ) {

    self.managedItems = viewControllers.map { .init(viewController: $0) }
    super.init(nibName: nil, bundle: nil)
  }

  open override func viewDidLoad() {
    super.viewDidLoad()

    view.clipsToBounds = true

    let panGesture = FluidPanGestureRecognizer(
      target: self,
      action: #selector(_onPanGesture(gesture:))
    )
    view.addGestureRecognizer(panGesture)

    let leftEdgeGesture = _EdgePanGestureRecognizer(
      target: self,
      action: #selector(_onLeftEdgeGesture(gesture:))
    )
    leftEdgeGesture.edges = .left
    view.addGestureRecognizer(leftEdgeGesture)

    let rightEdgeGesture = _EdgePanGestureRecognizer(
      target: self,
      action: #selector(_onRightEdgeGesture(gesture:))
    )
    rightEdgeGesture.edges = .right
    view.addGestureRecognizer(rightEdgeGesture)

    managedItems[currentIndex].register(parent: self)
    managedItems[currentIndex].display(in: view)
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Gesture

  let left = AnyFluidSpaceEnterInteraction.slide(direction: .left)
  let right = AnyFluidSpaceEnterInteraction.slide(direction: .right)

  @objc private func _onPanGesture(gesture: FluidPanGestureRecognizer) {
    print("gesture", gesture.translation(in: view))

    let translationX = gesture.translation(in: view).x

    let current = managedItems[currentIndex]

    if translationX > 0 {
      // right

      let nextIndex = managedItems.index(before: currentIndex)
      guard let next = managedItems[safe: nextIndex] else {
        return
      }

      next.register(parent: self)
      next.display(in: view)

      for handler in right.handlers {
        if case .gestureOnScreen(_, let handler) = handler {
          handler(
            gesture,
            .init(
              enteringViewController: next.viewController,
              leavingViewController: current.viewController,
              onEvent: { [weak self] event in
                switch event {
                case .onCompleted:
                  self?.currentIndex = nextIndex
                }
              }
            )
          )
        }
      }

    } else {
      // left

      let nextIndex = managedItems.index(after: currentIndex)
      guard let next = managedItems[safe: managedItems.index(after: currentIndex)] else {
        return
      }

      next.register(parent: self)
      next.display(in: view)

      for handler in left.handlers {
        if case .gestureOnScreen(_, let handler) = handler {
          handler(
            gesture,
            .init(
              enteringViewController: next.viewController,
              leavingViewController: current.viewController,
              onEvent: { [weak self] event in
                switch event {
                case .onCompleted:
                  self?.currentIndex = nextIndex
                }
              }
            )
          )
        }
      }
    }

  }

  @objc private func _onLeftEdgeGesture(gesture: UIScreenEdgePanGestureRecognizer) {

  }

  @objc private func _onRightEdgeGesture(gesture: UIScreenEdgePanGestureRecognizer) {

  }

}

public struct AnyFluidSpaceEnterInteraction {

  @MainActor
  public struct Context: CustomReflectable {

    public enum Event {
      case onCompleted
    }

    public let enteringViewController: UIViewController
    public let leavingViewController: UIViewController

    private let eventHandler: @MainActor (Event) -> Void

    init(
      enteringViewController: UIViewController,
      leavingViewController: UIViewController,
      onEvent: @escaping @MainActor (Event) -> Void
    ) {
      self.enteringViewController = enteringViewController
      self.leavingViewController = leavingViewController
      self.eventHandler = onEvent
    }

    public nonisolated var customMirror: Mirror {
      .init(
        self,
        children: [
          ("entering", enteringViewController),
          ("leaving", leavingViewController),
        ],
        displayStyle: .struct
      )
    }

    func send(event: Event) {
      self.eventHandler(event)
    }
  }

  public enum GestureConditionEvent {
    case shouldBeRequiredToFailBy(
      otherGestureRecognizer: UIGestureRecognizer,
      completion: @MainActor (Bool) -> Void
    )
    case shouldRecognizeSimultaneouslyWith(
      otherGestureRecognizer: UIGestureRecognizer,
      completion: @MainActor (Bool) -> Void
    )
  }

  public typealias GestureHandler<Gesture> = @MainActor (Gesture, Context) -> Void

  public typealias GestureCondition<Gesture> = @MainActor (Gesture, GestureConditionEvent) -> Void

  public enum Handler {
    case gestureOnLeftEdge(
      condition: GestureCondition<UIScreenEdgePanGestureRecognizer>,
      handler: GestureHandler<UIScreenEdgePanGestureRecognizer>
    )
    case gestureOnScreen(
      condition: GestureCondition<FluidPanGestureRecognizer>,
      handler: GestureHandler<FluidPanGestureRecognizer>
    )
  }

  public let handlers: [Handler]

  /// Creates an instance
  /// - Parameter handlers: Don't add duplicated handlers
  public init(
    handlers: [Handler]
  ) {
    self.handlers = handlers
  }

  /// Creates an instance
  /// - Parameter handlers: Don't add duplicated handlers
  public init(
    handlers: Handler...
  ) {
    self.handlers = handlers
  }

  public enum Direction {
    case right
    case left
  }

  public static func slide(direction: Direction) -> Self {

    struct TrackingContext {

      let viewFrame: CGRect
      let initialTranslateX: CGFloat

      func normalizedVelocity(gesture: UIPanGestureRecognizer) -> CGFloat {
        let velocityX = gesture.velocity(in: gesture.view).x
        return velocityX / viewFrame.width
      }

      func _translateX(gesture: UIPanGestureRecognizer) -> CGFloat {
        return gesture.translation(in: nil).x  // + initialTranslateX
      }
    }

    var trackingContext: TrackingContext?

    return Self.init(handlers: [
      .gestureOnScreen(
        condition: { gesture, event in

        },
        handler: { gesture, context in

          let enteringView = context.enteringViewController.view!
          let leavingView = context.leavingViewController.view!

          switch gesture.state {
          case .possible:
            break
          case .began:

            //            enteringView.layer.removeAllAnimations()
            //            leavingView.layer.removeAllAnimations()

            fallthrough
          case .changed:

            if trackingContext == nil {

              let newTrackingContext = TrackingContext(
                viewFrame: enteringView.bounds,
                initialTranslateX: enteringView.transform.tx
              )

              trackingContext = newTrackingContext

            }

            if let context = trackingContext {

              switch direction {
              case .right:
                enteringView.transform = .init(
                  translationX: context._translateX(gesture: gesture) - enteringView.bounds.width,
                  y: 0
                )
                leavingView.transform = .init(
                  translationX: context._translateX(gesture: gesture),
                  y: 0
                )
              case .left:
                enteringView.transform = .init(
                  translationX: context._translateX(gesture: gesture) + enteringView.bounds.width,
                  y: 0
                )
                leavingView.transform = .init(
                  translationX: context._translateX(gesture: gesture),
                  y: 0
                )
              }

            }

          case .ended, .cancelled, .failed:

            guard let _trackingContext = trackingContext else {
              Log.error(.default, "Got unexpedted case")
              return
            }

            let velocity = gesture.velocity(in: gesture.view)
            let progress = 1 - (abs(enteringView.transform.tx) / enteringView.bounds.width)

            if progress > 0.4 || abs(velocity.x) > 300 {

              let initialVelocity = CGVector(
                dx: abs(velocity.x) / (enteringView.bounds.width - abs(enteringView.transform.tx)),
                dy: 0
              )
              
              let animator = UIViewPropertyAnimator(
                duration: 0.6,
                timingParameters: UISpringTimingParameters(
                  dampingRatio: 100,
                  initialVelocity: initialVelocity
                )
              )

              animator.addAnimations {
                switch direction {
                case .right:
                  enteringView.transform = .identity
                  leavingView.transform = .init(translationX: leavingView.bounds.width, y: 0)
                case .left:
                  enteringView.transform = .identity
                  leavingView.transform = .init(translationX: -leavingView.bounds.width, y: 0)
                }

              }

              animator.startAnimation()
              context.send(event: .onCompleted)
            } else {

              let initialVelocity = CGVector(
                dx: abs(velocity.x) / abs(enteringView.transform.tx),
                dy: 0
              )

              let animator = UIViewPropertyAnimator(
                duration: 0.6,
                timingParameters: UISpringTimingParameters(
                  dampingRatio: 1,
                  initialVelocity: initialVelocity
                )
              )

              animator.addAnimations {

                switch direction {
                case .right:
                  enteringView.transform = .init(translationX: -leavingView.bounds.width, y: 0)
                  leavingView.transform = .identity
                case .left:
                  enteringView.transform = .init(translationX: leavingView.bounds.width, y: 0)
                  leavingView.transform = .identity
                }
              }

              animator.startAnimation()
            }

            trackingContext = nil
        
          /// restore view state
          @unknown default:
            break
          }

        }
      )
    ])
  }
}

public struct AnyFluidSpaceLeaveInteraction {

}

public struct AnyFluidSpaceEnterTransition {

  public let name: String

}

public struct AnyFluidSpaceLeaveTransition {

  public let name: String

}

public final class FluidSpaceTransitionContext {

}

extension Collection {
  fileprivate subscript(safe index: Index) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }
}
