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

  public static func makePropertyAnimatorsForTranform(
    view: UIView,
    duration: TimeInterval,
    transform: CGAffineTransform,
    velocityForTranslation: CGVector
  ) -> [UIViewPropertyAnimator] {

    let txAnimator = UIViewPropertyAnimator(
      duration: duration,
      timingParameters: UISpringTimingParameters.init(
        dampingRatio: 1,
        initialVelocity: .init(dx: velocityForTranslation.dx, dy: 0)
      )
    )

    let tyAnimator = UIViewPropertyAnimator(
      duration: duration,
      timingParameters: UISpringTimingParameters.init(
        dampingRatio: 1,
        initialVelocity: .init(dx: velocityForTranslation.dy, dy: 0)
      )
    )

    let scaleAnimator = UIViewPropertyAnimator(
      duration: duration,
      timingParameters: UISpringTimingParameters.init(
        dampingRatio: 1,
        initialVelocity: .init(dx: 0, dy: 0)
      )
    )

    scaleAnimator.addAnimations {
      view.transform.a = transform.a
      view.transform.b = transform.b
      view.transform.c = transform.c
      view.transform.d = transform.d
    }

    txAnimator.addAnimations {
      view.transform.tx = transform.tx
    }

    tyAnimator.addAnimations {
      view.transform.ty = transform.ty
    }

    return [
      txAnimator,
      tyAnimator,
      scaleAnimator,
    ]
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

    print("\(velocityForScaling)")

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
