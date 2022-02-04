import Foundation
import MondrianLayout
import UIKit

final class DemoCompositionOrderViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground

    let entrypoint = UIView()

    Mondrian.buildSubviews(on: view) {
      ZStackBlock {
        VStackBlock {
          ZStackBlock {
            entrypoint
              .viewBlock
              .size(.init(width: 120, height: 60))
          }

          UIButton.make(title: "toggle clipping") {
            entrypoint.clipsToBounds.toggle()
          }

        }
      }
      .container(respectingSafeAreaEdges: .all)
    }

    entrypoint.backgroundColor = .neon(.cyan)

    let reparentView = UIView()
    reparentView.backgroundColor = .neon(.red)

    Mondrian.buildSubviews(on: entrypoint) {
      ZStackBlock {
        reparentView
          .viewBlock
          .padding(.top, -200)
          .padding(.horizontal, 20)
      }
    }

  }

}
