import CompositionKit
import MondrianLayout
import Ne
import UIKit

@testable import FluidStack

final class ScalingVelocityPlaygroundViewController: UIViewController {

  private let box0 = UIView.mock(backgroundColor: .init(white: 0.5, alpha: 1))
  private let box1 = UIView.mock(backgroundColor: .neon(.blue))
  private let box2 = UIView.mock(backgroundColor: .neon(.red))
  private let box3 = UIView.mock(backgroundColor: .neon(.purple))
  private let box4 = UIView.mock(backgroundColor: .neon(.violet))

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground

    let startButton = UIButton.make(title: "Start") {

      let duration: CGFloat = 5
      let scale: CGFloat = 0.2
      let transform = CGAffineTransform.init(scaleX: scale, y: scale)
      let delta: CGFloat = 1 - scale

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
          box0.transform = transform
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
          box1.transform = transform
        }
        a.startAnimation()
      }

      do {
        let a = UIViewPropertyAnimator(
          duration: duration,
          timingParameters: UISpringTimingParameters(
            dampingRatio: 1,
            initialVelocity: .init(dx: 10, dy: 0)
          )
        )
        a.addAnimations { [unowned self] in
          box2.transform = transform
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

            VStackBlock(spacing: 4, alignment: .leading) {

              let size = CGSize(width: 100, height: 100)

              box0
                .viewBlock
                .size(size)
              box1
                .viewBlock
                .size(size)
              box2
                .viewBlock
                .size(size)

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
