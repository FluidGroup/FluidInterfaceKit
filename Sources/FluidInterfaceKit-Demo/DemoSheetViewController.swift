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
              
              fluidPush(controller, target: .current, relation: .modality)
              
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

private final class DetailViewController: FluidViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .neon(.purple)
  }
}

extension AnyRemovingInteraction {
  
  static var sheet: Self {
    
    return .init(handlers: [
      .gestureOnScreen(
        condition: { _, _ in
          
        },
        handler: { gesture, context in
                      
      })
    ])
    
  }
  
}
