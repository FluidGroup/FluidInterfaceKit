import CompositionKit
import MondrianLayout
import Ne
import UIKit

@testable import FluidStack

final class TranslationVelocityPlaygroundViewController: UIViewController {

  private let box0 = UIView.mock(backgroundColor: .init(white: 0.5, alpha: 1))
  private let box1 = UIView.mock(backgroundColor: .neon(.blue))
  private let box2 = UIView.mock(backgroundColor: .neon(.red))
  private let box3 = UIView.mock(backgroundColor: .neon(.purple))
  private let box4 = UIView.mock(backgroundColor: .neon(.violet))

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground

    let startButton = UIButton.make(title: "Start") {

      let duration: CGFloat = 10
      let translationX: CGFloat = 100

      func velocity(translationX: CGFloat, initPointsPerSec: CGFloat) -> CGFloat {
        translationX / initPointsPerSec
      }

      /// base
      do {
        let a = UIViewPropertyAnimator(
          duration: duration,
          timingParameters: UICubicTimingParameters(animationCurve: .linear)
        )
        a.addAnimations { [unowned self] in
          box0.layer.transform = CATransform3DMakeAffineTransform(.init(translationX: translationX, y: 0))
        }
        a.startAnimation()
      }

      do {
        let a = UIViewPropertyAnimator(
          duration: duration,
          timingParameters: UISpringTimingParameters(
            dampingRatio: 1,
            initialVelocity: .init(dx: 0, dy: 0)
          )
        )
        a.addAnimations { [unowned self] in
          box1.layer.transform = CATransform3DMakeAffineTransform(.init(translationX: translationX, y: 0))
        }
        a.startAnimation()
      }

      do {
        let a = UIViewPropertyAnimator(
          duration: duration,
          timingParameters: UISpringTimingParameters(
            dampingRatio: 1,
            initialVelocity: .init(dx: velocity(translationX: translationX, initPointsPerSec: 10), dy: 0)
          )
        )
        a.addAnimations { [unowned self] in
          box2.layer.transform = CATransform3DMakeAffineTransform(.init(translationX: translationX, y: 0))
        }
        a.startAnimation()
      }

      do {
        let a = UIViewPropertyAnimator(
          duration: duration,
          timingParameters: UISpringTimingParameters(
            dampingRatio: 1,
            initialVelocity: .init(dx: -5, dy: 0)
          )
        )
        a.addAnimations { [unowned self] in
          box3.layer.transform = CATransform3DMakeAffineTransform(.init(translationX: translationX, y: 0))
        }
        a.startAnimation()
      }

      do {
        let a = UIViewPropertyAnimator(
          duration: duration,
          timingParameters: UISpringTimingParameters(
            dampingRatio: 1,
            initialVelocity: .init(dx: 5, dy: 0)
          )
        )
        a.addAnimations { [unowned self] in
          box4.layer.transform = CATransform3DMakeAffineTransform(.init(translationX: translationX, y: 0))
        }
        a.startAnimation()
      }


    }

    let resetButton = UIButton.make(title: "Reset") { [unowned self] in

      box0.layer.transform = CATransform3DIdentity
      box1.layer.transform = CATransform3DIdentity
      box2.layer.transform = CATransform3DIdentity
      box3.layer.transform = CATransform3DIdentity
      box4.layer.transform = CATransform3DIdentity

    }

    Mondrian.buildSubviews(on: view) {

      LayoutContainer(attachedSafeAreaEdges: .all) {
        ZStackBlock {

          VStackBlock(spacing: 20, alignment: .fill) {

            HStackBlock(spacing: 0, alignment: .center) {
              UIView.mock(backgroundColor: UIColor(white: 0.9, alpha: 1))
                .viewBlock
                .size(.init(width: 50, height: 10))
              UIView.mock(backgroundColor: UIColor(white: 0.9, alpha: 1))
                .viewBlock
                .size(.init(width: 50, height: 10))
              UIView.mock(backgroundColor: UIColor(white: 0.9, alpha: 1))
                .viewBlock
                .size(.init(width: 50, height: 10))
              UIView.mock(backgroundColor: UIColor(white: 0.9, alpha: 1))
                .viewBlock
                .size(.init(width: 50, height: 10))
            }
            .alignSelf(.leading)

            VStackBlock(spacing: 4, alignment: .leading) {

              box0
                .viewBlock
                .size(.init(width: 20, height: 20))
              box1
                .viewBlock
                .size(.init(width: 20, height: 20))
              box2
                .viewBlock
                .size(.init(width: 20, height: 20))
              box3
                .viewBlock
                .size(.init(width: 20, height: 20))
              box4
                .viewBlock
                .size(.init(width: 20, height: 20))

            }

            HStackBlock(spacing: 12, alignment: .center) {
              resetButton

              startButton
            }
            .alignSelf(.center)
          }
          .alignSelf(.attach(.horizontal))

        }
        .padding(24)
      }

    }
  }
}
