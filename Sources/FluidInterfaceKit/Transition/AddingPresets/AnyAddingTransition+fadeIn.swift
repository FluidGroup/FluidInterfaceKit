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
   - Scaling down
   - Fade in
   */
  public static var jump: Self {
    
    return .init { context in
      
      context.disableUserInteractionUntileFinish()
      
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
  
  /**
   - Scaling up
   - Fade in
   */
  public static var float: Self {
    
    return .init { context in
            
      context.contentView.backgroundColor = .clear
            
      let toView = context.toViewController.view!
      toView.transform = .init(scaleX: 0.8, y: 0.8)
      toView.alpha = 0
      
      let toLayer = toView.layer
      
      toLayer.masksToBounds = true
      toLayer.cornerCurve = .continuous
      toLayer.cornerRadius = 32
      
      let animator = UIViewPropertyAnimator(
        duration: 0.5,
        timingParameters: UISpringTimingParameters(dampingRatio: 0.9, initialVelocity: .zero)
      )
      
      animator.addAnimations {
        toLayer.cornerRadius = 0
        toView.alpha = 1
        toView.transform = .identity
        context.contentView.backgroundColor = .init(white: 0, alpha: 0.2)
      }
      
      animator.addCompletion { _ in
        context.contentView.backgroundColor = .clear
        context.notifyAnimationCompleted()
      }
      
      animator.startAnimation()
      
    }
    
  }
}
