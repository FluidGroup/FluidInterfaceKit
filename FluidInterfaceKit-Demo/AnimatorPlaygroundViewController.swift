import MondrianLayout
import Ne
import UIKit
@testable import FluidInterfaceKit

final class AnimatorPlaygroundViewController: UIViewController {

  struct State {
    var alphaFlag = false
  }

  private var state: State = .init()

  private let box1 = UIView.mock(backgroundColor: .neon(.blue))
  private let box2 = UIView.mock(backgroundColor: .neon(.red))
  private let box3 = UIView.mock(backgroundColor: .neon(.purple))
  private let box4 = UIView.mock(backgroundColor: .neon(.violet))

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white

    Mondrian.buildSubviews(on: view) {

      ZStackBlock {

        VStackBlock {

          VStackBlock {
            HStackBlock {
              box1
                .viewBlock
                .size(.init(width: 50, height: 50))
              box2
                .viewBlock
                .size(.init(width: 50, height: 50))
            }

            HStackBlock {
              box3
                .viewBlock
                .size(.init(width: 50, height: 50))
              box4
                .viewBlock
                .size(.init(width: 50, height: 50))
            }
          }

          VGridBlock(columns: [
            .init(.flexible(), spacing: 10),
            .init(.flexible(), spacing: 10),
          ]) {
            UIButton.make(title: "alpha") { [unowned self] in

              let a = UIViewPropertyAnimator(duration: 0.4, dampingRatio: 1) {
                box1.alpha = state.alphaFlag ? 1 : 0
              }
              a.startAnimation()

              box1.layer.dumpAllAnimations()

              state.alphaFlag.toggle()

            }
          }

        }
      }

    }

  }

}
