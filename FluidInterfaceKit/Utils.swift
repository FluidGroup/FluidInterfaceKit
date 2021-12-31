import Foundation
import UIKit

enum Fluid {

  public static func startPropertyAnimators(
    _ animators: [UIViewPropertyAnimator],
    completion: @escaping () -> Void
  ) {

    let group = DispatchGroup()

    group.enter()

    group.notify(queue: .main) {
      completion()
    }

    for animator in animators {
      group.enter()
      animator.addCompletion { _ in
        group.leave()
      }
    }

    for animator in animators {
      animator.startAnimation()
    }

    group.leave()

  }

  public enum Position {
    case center(of: CGRect)
    case custom(CGPoint)
  }

  public static func makePropertyAnimatorsForTranformUsingCenter(
    view: UIView,
    duration: TimeInterval,
    position: Position,
    scale: CGSize,
    velocityForTranslation: CGVector,
    velocityForScaling: CGFloat
  ) -> [UIViewPropertyAnimator] {

    let positionAnimator = UIViewPropertyAnimator(
      duration: duration,
      timingParameters: UISpringTimingParameters.init(
        dampingRatio: 1,
        initialVelocity: velocityForTranslation
      )
    )

    let scaleAnimator = UIViewPropertyAnimator(
      duration: duration,
      timingParameters: UISpringTimingParameters.init(
        dampingRatio: 1,
        initialVelocity: CGVector(dx: velocityForScaling, dy: 0)
      )
    )

    scaleAnimator.addAnimations {
      view.transform = .init(scaleX: scale.width, y: scale.height)
    }

    positionAnimator.addAnimations {

      switch position {
      case .center(let rect):

        view.layer.position = .init(x: rect.midX, y: rect.midY)

      case .custom(let value):

        view.layer.position = value
      }

    }

    return [
      positionAnimator,
      scaleAnimator,
    ]
  }

}
