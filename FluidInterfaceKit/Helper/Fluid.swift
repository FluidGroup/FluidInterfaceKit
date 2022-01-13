import Foundation
import UIKit
import GeometryKit

enum Fluid {

  public static func takeSnapshotVisible(view: UIView) -> UIView {

    let snapshot: UIView

    if view.alpha == 1, view.isHidden == false {
      snapshot = view.snapshotView(afterScreenUpdates: false) ?? UIView()
    } else {
      let alpha = view.alpha
      let isHidden = view.isHidden
      let frame = view.frame

      view.alpha = 1
      view.isHidden = false
      view.frame.origin.x = 10000 // move to out of the screen to avoid blinking
      defer {
        view.alpha = alpha
        view.isHidden = isHidden
        view.frame = frame
      }
      snapshot = view.snapshotView(afterScreenUpdates: true) ?? UIView()
    }

    snapshot.isUserInteractionEnabled = false

    return snapshot
  }

  public static func hasAnimations(view: UIView) -> Bool {
    return (view.layer.animationKeys() ?? []).count > 0
  }

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
    scale: CGPoint,
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
      view.transform = .init(scaleX: scale.x, y: scale.y)
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

  public static func setFrameAsIdentity(_ frame: CGRect, for view: UIView) {

    let center = Geometry.center(of: frame)
    view.bounds.size = frame.size
    view.center = center

  }

}
