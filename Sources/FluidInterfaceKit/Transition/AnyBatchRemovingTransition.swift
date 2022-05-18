import UIKit

/**
 A transition for removing in ``FluidStackController`` or ``TransitionViewController``
 */
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

extension AnyBatchRemovingTransition {
  
  public static var disabled: Self {
    return .init { context in
      context.notifyCompleted()
    }
  }
  
  @available(*, deprecated, renamed: "disabled")
  public static var noAnimation: Self {
    return disabled
  }

  public static var crossDissolve: Self {

    return .init { context in

      let topViewController = context.fromViewControllers.last!
      let middleViewControllers = context.fromViewControllers.dropLast()

      middleViewControllers.forEach {
        $0.view.isHidden = true
      }

      let animator = UIViewPropertyAnimator(duration: 0.6, dampingRatio: 1) {

        topViewController.view.alpha = 0

        context.toViewController?.view.transform = .identity
        context.toViewController?.view.alpha = 1

      }

      animator.addCompletion { _ in

        context.notifyCompleted()

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

  public static var springFlourish: Self {
    
    return .init { context in
      
      let animators: [UIViewPropertyAnimator] = context.fromViewControllers
        .reversed()
        .enumerated()
        .map { i, viewController in
          
          let animator = UIViewPropertyAnimator(duration: 0.6 + (Double(i) * 0.2), dampingRatio: 1) {
            
            viewController.view.transform = .init(translationX: 0, y: viewController.view.bounds.height)
            
          }
          
          return animator
          
        }
      
      Fluid.startPropertyAnimators(animators) {
        context.notifyCompleted()
      }

    }
    
  }
  
  public static var modalStyle: Self {
    
    return .init { context in
      
      let topViewController = context.fromViewControllers.last!
      let middleViewControllers = context.fromViewControllers.dropLast()

      middleViewControllers.forEach {
        $0.view.isHidden = true
      }

      context.contentView.backgroundColor = .clear

      let animator = UIViewPropertyAnimator(duration: 0.6, dampingRatio: 1) {

        topViewController.view.layer.transform = CATransform3DMakeAffineTransform(.init(
          translationX: 0,
          y: topViewController.view.bounds.height
        ))
        topViewController.view.alpha = 1
        
        context.toViewController?.view.transform = .identity
        context.toViewController?.view.alpha = 1
      }

      animator.addCompletion { _ in
        context.notifyCompleted()
      }

      animator.startAnimation()
      
    }
    
  }
  
}
