#if !COCOAPODS
import FluidInterfaceKit
#endif

import Rideau
import UIKit

/// An Object that displays an RideauView with Presentation.
///
/// - FIXME: When specified ``.noAnimation``, it won't display anything.
open class FluidRideauViewController: FluidTransitionViewController {

  // MARK: - Properties

  public var onWillDismiss: () -> Void = {}

  public let rideauView: RideauView

  let backgroundView: UIView = .init()

  let backgroundColor: UIColor
  
  let initialSnapPoint: RideauSnapPoint

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

    self.initialSnapPoint = initialSnapPoint
    self.rideauView = .init(frame: .zero, configuration: c)

    self.backgroundColor = backdropColor

    super.init(
      content: nil,
      addingTransition: .rideau,
      removingTransition: .rideau
    )
    
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

  }

  @available(*, unavailable)
  public required init?(
    coder aDecoder: NSCoder
  ) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Functions
  
  open override func viewDidLoad() {
    super.viewDidLoad()
    
    fluidStackContentConfiguration.contentType = .overlay
    
  }

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

      UIViewPropertyAnimator(duration: 0.6, dampingRatio: 1) {
        self?.backgroundView.backgroundColor = .clear
      }
      .startAnimation()

    }
      
    rideauView.handlers.didMoveTo = { [weak self] point in

      guard let self = self else { return }

      guard point == .hidden else {
        return
      }
      
      guard let fluidStackContext = self.fluidStackContext else {
        return
      }
      
      self.onWillDismiss()
      fluidStackContext.removeSelf(transition: .noAnimation)

    }

  }

  @objc private dynamic func didTapBackdropView(gesture: UITapGestureRecognizer) {
    assert(fluidStackContext != nil)
    onWillDismiss()    
    fluidPop(transition: nil, completion: nil)

  }
}


extension AnyAddingTransition {
  
  public static var rideau: Self {
    .init { context in
      
      guard let controller = context.toViewController as? FluidRideauViewController else {
        context.notifyAnimationCompleted()
        return
      }
            
      // TODO: Use rideauView.handlers.animatorsAlongsideMoving instead
      UIViewPropertyAnimator(duration: 0.6, dampingRatio: 1) {
        controller.backgroundView.backgroundColor = controller.backgroundColor
      }
      .startAnimation()
      
      controller.rideauView.move(
        to: controller.initialSnapPoint,
        animated: true,
        completion: {
          context.notifyAnimationCompleted()
      })
                                   
    }
  }
}

extension AnyRemovingTransition {
  
  public static var rideau: Self {
    .init { context in
      
      guard let controller = context.fromViewController as? FluidRideauViewController else {
        context.notifyAnimationCompleted()
        return
      }
          
      // TODO: Use rideauView.handlers.animatorsAlongsideMoving instead
      UIViewPropertyAnimator(duration: 0.6, dampingRatio: 1) {
        controller.backgroundView.backgroundColor = .clear
      }
      .startAnimation()
      
      controller.rideauView.move(
        to: .hidden,
        animated: true,
        completion: {
          context.notifyAnimationCompleted()
      })
             
      
    }
  }
  
}
