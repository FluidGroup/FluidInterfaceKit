import UIKit

extension AnyAddingTransition {

  public static func fadeIn(
    duration: TimeInterval = 0.6
  ) -> Self {

    return .init { context in

      context.contentView.backgroundColor = .clear
      context.toViewController.view.alpha = 0

      let animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
        context.toViewController.view.alpha = 1
      }

      animator.addCompletion { _ in
        context.notifyAnimationCompleted()
      }

      animator.startAnimation()

    }

  }
  
  /**
   Scaling up from shrinking state and fade-in.
   */
  public static var jump: Self {
    
    return .init { context in
      
      context.disableFlexibility()
      
      context.contentView.backgroundColor = .clear
      
      context.toViewController.view.transform = .init(scaleX: 1.08, y: 1.08)
      context.toViewController.view.alpha = 0
      
      let animator = UIViewPropertyAnimator(
        duration: 0.4,
        timingParameters: UISpringTimingParameters(dampingRatio: 1, initialVelocity: .zero)
      )
      
      animator.addAnimations {
        context.toViewController.view.alpha = 1
        context.toViewController.view.transform = .identity
      }
      
      animator.addCompletion { _ in
        context.notifyAnimationCompleted()
      }
      
      animator.startAnimation()
      
    }
    
  }
}
