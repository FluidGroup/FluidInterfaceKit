#if !COCOAPODS
import FluidInterfaceKit
#endif

import Rideau
import UIKit

/// An Object that displays an RideauView with Presentation.
///
/// - FIXME: When specified ``.noAnimation``, it won't display anything.
open class FluidRideauViewController: FluidTransitionViewController {
  
  /**
   Whether supports modal-presentation.
   For transition period.
   */
  public static var supportsModalPresentation = true

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
    
    if Self.supportsModalPresentation {
      self.modalPresentationStyle = .overFullScreen
      self.transitioningDelegate = self
    }
    
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
                  
      self.onWillDismiss()
      
      if Self.supportsModalPresentation {
        
        if self.isInFluidStackController {
          self.fluidStackContext?.removeSelf(transition: .noAnimation)
        } else {
          self.dismiss(animated: true, completion: nil)
        }
              
      } else {
        self.fluidStackContext?.removeSelf(transition: .noAnimation)
      }

    }

  }

  @objc private dynamic func didTapBackdropView(gesture: UITapGestureRecognizer) {
    
    if Self.supportsModalPresentation {
      
      if self.isInFluidStackController {
        assert(fluidStackContext != nil)
        onWillDismiss()
        fluidPop(transition: nil, completion: nil)
      } else {
        self.dismiss(animated: true, completion: nil)
      }
            
    } else {
      assert(fluidStackContext != nil)
      onWillDismiss()
      fluidPop(transition: nil, completion: nil)
    }
    
    

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

extension FluidRideauViewController: UIViewControllerTransitioningDelegate {

  public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

    return __RideauPresentTransitionController(targetSnapPoint: initialSnapPoint, backgroundColor: backgroundColor)
  }

  public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {

    // WORKAROUND: Currently, we can not get the timing of beginning dismissal.
    onWillDismiss()
    return __RideauDismissTransitionController()
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

extension UIViewController {
    
  /**
   Displays given instance of ``FluidRideauViewController`` on ``FluidStackController``.
   */
  public func fluidPush(
    _ viewController: FluidRideauViewController,
    target strategy: FluidStackFindStrategy
  ) {
    fluidPushUnsafely(viewController, target: strategy, transition: nil)
  }
  
}


// MARK: - Modal-presentation support

fileprivate final class __RideauPresentTransitionController: NSObject, UIViewControllerAnimatedTransitioning {

  let targetSnapPoint: RideauSnapPoint
  let backgroundColor: UIColor

  init(
    targetSnapPoint: RideauSnapPoint,
    backgroundColor: UIColor
  ) {
    self.targetSnapPoint = targetSnapPoint
    self.backgroundColor = backgroundColor
    super.init()
  }

  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.3
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

    guard let controller = transitionContext.viewController(forKey: .to) as? FluidRideauViewController else {
      fatalError()
    }

    transitionContext.containerView.addSubview(controller.view)

    transitionContext.containerView.layoutIfNeeded()

    transitionContext.completeTransition(true)

    controller.backgroundView.backgroundColor = UIColor(white: 0, alpha: 0)

    UIView.animate(
      withDuration: 0.4,
      delay: 0,
      usingSpringWithDamping: 1,
      initialSpringVelocity: 0,
      options: [.beginFromCurrentState],
      animations: {
        controller.backgroundView.backgroundColor = self.backgroundColor
      },
      completion: nil
    )

    controller.rideauView.move(to: targetSnapPoint, animated: true) {
    }
  }
}

fileprivate final class __RideauDismissTransitionController: NSObject, UIViewControllerAnimatedTransitioning {
  
  override init() {
    super.init()
  }

  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

    guard let controller = transitionContext.viewController(forKey: .from) as? FluidRideauViewController else {
      fatalError()
    }

    UIView.animate(
      withDuration: 0.3,
      delay: 0,
      usingSpringWithDamping: 1,
      initialSpringVelocity: 0,
      options: [.beginFromCurrentState, .allowUserInteraction],
      animations: {
        controller.backgroundView.backgroundColor = UIColor(white: 0, alpha: 0)
      },
      completion: { _ in
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
      }
    )

    controller.rideauView.move(to: .hidden, animated: true) {
    }
  }
}
