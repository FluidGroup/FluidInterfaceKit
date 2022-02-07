import CompositionKit
import FluidInterfaceKit
import Foundation
import MondrianLayout
import UIKit

final class DemoCompositionOrderViewController: UIViewController {

  let scrollView = ScrollableContainerView()
  let portalView = PortalView()

  override func viewDidLoad() {
    super.viewDidLoad()

    Mondrian.buildSubviews(on: view) {
      ZStackBlock {
        scrollView
          .viewBlock
          .alignSelf(.attach(.all))
        
        portalView
          .viewBlock
          .padding(.top, 400)
          .alignSelf(.attach(.all))
      }
    }

    view.backgroundColor = .systemBackground

    let entrypoint = UIView()

    let contentView = AnyView { _ in
      VStackBlock {
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
    }

    scrollView.setContent(contentView)
    scrollView.alwaysBounceVertical = true

    entrypoint.backgroundColor = .neon(.cyan)

    let reparentingView = ReparentingView()
    reparentingView.backgroundColor = .neon(.red).withAlphaComponent(0.6)

    entrypoint.addSubview(reparentingView)
    
    let animatingView = UIView()
    
    portalView.sourceLayer = animatingView.layer
    portalView.matchesPosition = true

    Mondrian.buildSubviews(on: reparentingView) {
      ZStackBlock {
        animatingView
          .viewBlock
          .width(200)
          .height(120)
      }
    }

    animatingView.backgroundColor = .neon(.purple)

    UIView.animate(
      withDuration: 0.6,
      delay: 0,
      usingSpringWithDamping: 1,
      initialSpringVelocity: 0,
      options: [.autoreverse, .repeat]
    ) {
      animatingView.backgroundColor = .neon(.cyan)
    } completion: { _ in

    }

  }

}
