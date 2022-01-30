#if !COCOAPODS
import FluidInterfaceKit
#endif

import Rideau
import UIKit

/// An Object that displays an RideauView with Presentation.
open class FluidRideauViewController: UIViewController {

  // MARK: - Properties

  public var onWillDismiss: () -> Void = {}

  public let rideauView: RideauView

  let backgroundView: UIView = .init()

  private let backgroundColor: UIColor

  // MARK: - Initializers

  public init(
    bodyViewController: UIViewController,
    configuration: RideauView.Configuration,
    initialSnapPoint: RideauSnapPoint,
    resizingOption: RideauContentContainerView.ResizingOption,
    backdropColor: UIColor = UIColor(white: 0, alpha: 0.2),
    usesDismissalPanGestureOnBackdropView: Bool = true
  ) {

    precondition(configuration.snapPoints.contains(initialSnapPoint))

    var c = configuration

    c.snapPoints.insert(.hidden)

    self.rideauView = .init(frame: .zero, configuration: c)

    self.backgroundColor = backdropColor

    super.init(nibName: nil, bundle: nil)
    
    self.backgroundView.backgroundColor = .clear

    do {

      if usesDismissalPanGestureOnBackdropView {

        let pan = UIPanGestureRecognizer()

        backgroundView.addGestureRecognizer(pan)

        rideauView.register(other: pan)

      }

    }

    do {
      let tap = UITapGestureRecognizer(target: self, action: #selector(didTapBackdropView))
      backgroundView.addGestureRecognizer(tap)

      view.addSubview(backgroundView)

      backgroundView.frame = view.bounds
      backgroundView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

      view.addSubview(rideauView)
      rideauView.frame = view.bounds
      rideauView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

      // To create resolveConfiguration
      view.layoutIfNeeded()

      set(bodyViewController: bodyViewController, to: rideauView, resizingOption: resizingOption)

      view.layoutIfNeeded()
    }

    fluidStackActionHandler = { [weak self] action in
      guard let self = self else { return }
      switch action {
      case .didSetContext:
        break
      case .didDisplay:
        self.rideauView.move(to: initialSnapPoint, animated: true, completion: {})
        UIViewPropertyAnimator(duration: 0.6, dampingRatio: 1) {
          self.backgroundView.backgroundColor = self.backgroundColor
        }
        .startAnimation()
      }
    }
  }

  @available(*, unavailable)
  public required init?(
    coder aDecoder: NSCoder
  ) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Functions

  open func set(
    bodyViewController: UIViewController,
    to rideauView: RideauView,
    resizingOption: RideauContentContainerView.ResizingOption
  ) {
    bodyViewController.willMove(toParent: self)
    addChild(bodyViewController)
    rideauView.containerView.set(bodyView: bodyViewController.view, resizingOption: resizingOption)
  }

  open override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    rideauView.handlers.willMoveTo = { [weak self] point in

      guard point == .hidden else {
        return
      }

      UIView.animate(
        withDuration: 0.3,
        delay: 0,
        usingSpringWithDamping: 1,
        initialSpringVelocity: 0,
        options: [.beginFromCurrentState, .allowUserInteraction],
        animations: {
          self?.backgroundView.backgroundColor = UIColor(white: 0, alpha: 0)
        },
        completion: { _ in

        }
      )

    }

    rideauView.handlers.didMoveTo = { [weak self] point in

      guard let self = self else { return }

      guard point == .hidden else {
        return
      }
      assert(self.fluidStackContext != nil)

      self.onWillDismiss()
      self.fluidStackContext?.removeSelf(transition: .noAnimation)

    }

  }

  @objc private dynamic func didTapBackdropView(gesture: UITapGestureRecognizer) {
    assert(fluidStackContext != nil)
    onWillDismiss()

    // move snappoint to .hidden
    // it triggers `rideauView.handlers.didMoveTo`, then dimiss.
    rideauView.move(
      to: .hidden,
      animated: true,
      completion: {
      }
    )

  }
}
