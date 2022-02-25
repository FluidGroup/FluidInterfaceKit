import CompositionKit
import MondrianLayout
import Ne
import UIKit

@testable import FluidInterfaceKit

final class AnimatorPlaygroundViewController: UIViewController {

  struct State {
    var alphaFlag = false
    var positionFlag = false
  }

  private var state: State = .init()

  private let box1 = UIView.mock(backgroundColor: .neon(.blue))
  private let box2 = UIView.mock(backgroundColor: .neon(.red))
  private let box3 = UIView.mock(backgroundColor: .neon(.purple))
  private let box4 = UIView.mock(backgroundColor: .neon(.violet))

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground

    Mondrian.buildSubviews(on: view) {

      ZStackBlock {

        VStackBlock {

          VStackBlock {
            HStackBlock {
              InteractiveView(animation: .bodyShrink, contentView: box1)&>.do { view in
                view.handlers.onTap = { [unowned view] in

                  do {
                    let animator = UIViewPropertyAnimator(
                      duration: 6,
                      timingParameters: UISpringTimingParameters.init(
                        dampingRatio: 1,
                        initialVelocity: .init(dx: -2, dy: 0)
                      )
                    )

                    animator.addAnimations {
                      view.transform.tx = -50
                    }

                    animator.startAnimation()
                  }

                  do {
                    let animator = UIViewPropertyAnimator(
                      duration: 6,
                      timingParameters: UISpringTimingParameters.init(
                        dampingRatio: 1,
                        initialVelocity: .init(dx: 10, dy: 0)
                      )
                    )

                    animator.addAnimations {
                      view.transform.ty = -50
                    }

                    animator.startAnimation()
                  }

                  do {
                    let animator = UIViewPropertyAnimator(
                      duration: 6,
                      timingParameters: UISpringTimingParameters.init(
                        dampingRatio: 1,
                        initialVelocity: .init(dx: 0, dy: 0)
                      )
                    )

                    animator.addAnimations {
                      view.transform.a = 0.8
                      view.transform.d = 0.8
                    }

                    animator.startAnimation()
                  }
                  view.layer.dumpAllAnimations()
                }
              }
              .viewBlock
              .size(.init(width: 50, height: 50))

              InteractiveView(animation: .bodyShrink, contentView: box2)&>.do { view in
                view.handlers.onTap = { [unowned view] in

                  let animations = makeTransformAnimations(from: .identity, to: .init(scaleX: 0.8, y: 0.8).translatedBy(x: 50, y: -50))

                  animations.forEach { i, e in
                    view.layer.add(e, forKey: i)
                  }

                  view.layer.dumpAllAnimations()
                }
              }
              .viewBlock
              .size(.init(width: 50, height: 50))
            }

            HStackBlock {
              InteractiveView(animation: .bodyShrink, contentView: box3)&>.do {
                $0.handlers.onTap = {



                }
              }
              .viewBlock
              .size(.init(width: 50, height: 50))
              InteractiveView(animation: .bodyShrink, contentView: box4)&>.do {
                $0.handlers.onTap = {}
              }
              .viewBlock
              .size(.init(width: 50, height: 50))
            }
          }

          VGridBlock(columns: [
            .init(.flexible(), spacing: 10),
            .init(.flexible(), spacing: 10),
          ]) {
            UIButton.make(title: "alpha") { [unowned self] in

              let a = UIViewPropertyAnimator(duration: 0.4, dampingRatio: 1) { [unowned self] in
                box1.alpha = state.alphaFlag ? 1 : 0
              }
              a.startAnimation()

              box1.layer.dumpAllAnimations()

              state.alphaFlag.toggle()

            }

            UIButton.make(title: "position") { [unowned self] in

              if state.positionFlag {

                let a = UIViewPropertyAnimator(duration: 3, timingParameters: UISpringTimingParameters(dampingRatio: 1, initialVelocity: .init(dx: 10, dy: 0)))
                a.addAnimations {
                  box2.transform = CGAffineTransform.init(translationX: 20, y: 0)
                }
                a.startAnimation()
              } else {

                let a = UIViewPropertyAnimator(duration: 3, timingParameters: UISpringTimingParameters(dampingRatio: 1, initialVelocity: .init(dx: 20, dy: 0)))
                a.addAnimations {
                  box2.transform = .identity
                }
                a.startAnimation()
              }


              box2.layer.dumpAllAnimations()

              state.positionFlag.toggle()

            }
          }

        }
      }

    }

  }

}

extension CASpringAnimation {

  /**
   Creates an instance from damping and response.
   the response calucation comes from https://medium.com/@nathangitter/building-fluid-interfaces-ios-swift-9732bb934bf5
   */
  convenience init(
    keyPath path: String?,
    damping: CGFloat,
    response: CGFloat,
    initialVelocity: CGFloat = 0
  ) {
    let stiffness = pow(2 * .pi / response, 2)
    let damp = 4 * .pi * damping / response

    self.init(keyPath: path)
    self.mass = 1
    self.stiffness = stiffness
    self.damping = damp
    self.initialVelocity = initialVelocity

  }
}

func makeTransformAnimations(from: CGAffineTransform, to: CGAffineTransform) -> [(String, CAAnimation)] {
  let duration: TimeInterval = 6

  let txAnimation = CASpringAnimation(
    keyPath: "transform.translation.x",
    damping: 1,
    response: 0.8,
    initialVelocity: -10
  )&>.do {
    $0.fromValue = from.tx
    $0.toValue = to.tx
    $0.fillMode = .both
    $0.isAdditive = true
    $0.isRemovedOnCompletion = false
    $0.duration = duration
  }

  let tyAnimation = CASpringAnimation(
    keyPath: "transform.translation.y",
    damping: 1,
    response: 0.8,
    initialVelocity: 40
  )&>.do {
    $0.fromValue = from.ty
    $0.toValue = to.ty
    $0.fillMode = .both
    $0.isAdditive = true
    $0.isRemovedOnCompletion = false
    $0.duration = duration
  }

  let scaleAnimation = CASpringAnimation(
    keyPath: "transform",
    damping: 1,
    response: 0.8,
    initialVelocity: 0
  )&>.do {
    $0.fromValue = NSValue(caTransform3D: CATransform3DMakeAffineTransform(.init(scaleX: from.a, y: from.d)))
    $0.toValue = NSValue(caTransform3D: CATransform3DMakeAffineTransform(.init(scaleX: to.a, y: to.d)))
    $0.fillMode = .both
    $0.isAdditive = true
    $0.isRemovedOnCompletion = false
    $0.duration = duration
  }

  return [
    (txAnimation.keyPath!, txAnimation),
    (tyAnimation.keyPath!, tyAnimation),
    (scaleAnimation.keyPath!, scaleAnimation),
  ]

}
