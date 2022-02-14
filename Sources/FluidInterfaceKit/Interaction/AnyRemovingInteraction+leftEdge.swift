import UIKit

extension AnyRemovingInteraction {
  
  /**
   Removes by left edge gesture
   */
  public static var leftEdge: Self {
        
    return .init(handlers: [
      .gestureOnLeftEdge { gesture, context in
        
        switch gesture.state {
        case .began:
          let transitionContext = context.startRemovingTransition()
          
          let animator = UIViewPropertyAnimator(duration: 0.6, dampingRatio: 1) {
            
            context.viewController.view.alpha = 0
            context.viewController.view.transform = .init(scaleX: 0.8, y: 0.8)
            transitionContext.contentView.backgroundColor = .clear
            
          }
          
          animator.addCompletion { _ in
            transitionContext.notifyAnimationCompleted()
          }
          
          animator.startAnimation()

        default:
          break
        }
      }
    ])
    
  }
    
}
