import CompositionKit
import FluidInterfaceKit
import FluidInterfaceKitRideauSupport
import Foundation
import MondrianLayout
import StorybookKit
import UIKit

final class DemoSheetViewController: FluidStackController {

  init() {
    super.init(rootViewController: ListViewController())
  }

}

private final class ListViewController: CodeBasedViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground

    Mondrian.buildSubviews(on: view) {
      
      ZStackBlock {
        VStackBlock {
          Components.makeSelection()&>.do {
            $0.handlers.onTap = { [unowned self] in
              
              let controller = DetailViewController()
              
              fluidPush(controller, target: .current)
              
              print("hey")
            }
          }
        }
      }
      
    }
  }

  private enum Components {

    static func makeSelection() -> InteractiveView<UIView> {

      return InteractiveView(
        animation: .bodyShrink,
        haptics: .impactOnTouchUpInside(),
        useLongPressGesture: false,
        contentView: AnyView { _ in

          VStackBlock {
            
            UILabel()&>.do {
              $0.text = "💡 Light bulb"
              $0.font = UIFont.boldSystemFont(ofSize: 16)
            }
            .viewBlock
            .padding(10)
            .background(ShapeLayerView.roundedCorner(radius: 6)&>.do {
              $0.shapeFillColor = .init(white: 0.5, alpha: 0.3)
            })
            
          }
          
        }
      )

    }

  }
}

private final class DetailViewController: FluidSheetViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .systemBackground
        
    let horizontalContent = ScrollableContainerView(scrollDirection: .horizontal)
    
    horizontalContent.setContent(AnyView { _ in
      HStackBlock(spacing: 8) {
        UIView.mock(backgroundColor: .neon(.purple), preferredSize: .init(width: 60, height: 60))
        UIView.mock(backgroundColor: .neon(.purple), preferredSize: .init(width: 60, height: 60))
        UIView.mock(backgroundColor: .neon(.purple), preferredSize: .init(width: 60, height: 60))
        UIView.mock(backgroundColor: .neon(.purple), preferredSize: .init(width: 60, height: 60))
        UIView.mock(backgroundColor: .neon(.purple), preferredSize: .init(width: 60, height: 60))
        UIView.mock(backgroundColor: .neon(.purple), preferredSize: .init(width: 60, height: 60))
        UIView.mock(backgroundColor: .neon(.purple), preferredSize: .init(width: 60, height: 60))
        UIView.mock(backgroundColor: .neon(.purple), preferredSize: .init(width: 60, height: 60))
      }
    })
    
    let verticalContent = ScrollableContainerView(scrollDirection: .vertical)
        
    verticalContent.setContent(AnyView { _ in
      VStackBlock(spacing: 8) {
        UIView.mock(backgroundColor: .neon(.purple), preferredSize: .init(width: 60, height: 60))
        UIView.mock(backgroundColor: .neon(.purple), preferredSize: .init(width: 60, height: 60))
        UIView.mock(backgroundColor: .neon(.purple), preferredSize: .init(width: 60, height: 60))
        UIView.mock(backgroundColor: .neon(.purple), preferredSize: .init(width: 60, height: 60))
        UIView.mock(backgroundColor: .neon(.purple), preferredSize: .init(width: 60, height: 60))
        UIView.mock(backgroundColor: .neon(.purple), preferredSize: .init(width: 60, height: 60))
        UIView.mock(backgroundColor: .neon(.purple), preferredSize: .init(width: 60, height: 60))
        UIView.mock(backgroundColor: .neon(.purple), preferredSize: .init(width: 60, height: 60))
        UIView.mock(backgroundColor: .neon(.purple), preferredSize: .init(width: 60, height: 60))
        UIView.mock(backgroundColor: .neon(.purple), preferredSize: .init(width: 60, height: 60))
        UIView.mock(backgroundColor: .neon(.purple), preferredSize: .init(width: 60, height: 60))
        UIView.mock(backgroundColor: .neon(.purple), preferredSize: .init(width: 60, height: 60))
      }
    })
    
    Mondrian.buildSubviews(on: view) {
      VStackBlock {
        horizontalContent
        
        verticalContent
      }
      .container(respectingSafeAreaEdges: .all)
    }
  }
}

