import CompositionKit
import FluidInterfaceKit
import MondrianLayout
import SwiftUI
import UIKit

final class DemoSpaceViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    let spaceViewController = FluidStageViewController(
      leftSideViewController: ContentViewController(color: .neonRandom(), title: "left"),
      mainViewController: ContentViewController(color: .neonRandom(), title: "main"),
      rightSideViewController: ContentViewController(color: .neonRandom(), title: "right")
    )

    addChild(spaceViewController)
    
    Mondrian.buildSubviews(on: view) {

      ZStackBlock(alignment: .attach(.all)) {
        spaceViewController.view
      }
    }

    spaceViewController.didMove(toParent: self)

  }
}

private final class ContentViewController: UIViewController {
  
  override func viewSafeAreaInsetsDidChange() {
    super.viewSafeAreaInsetsDidChange()
    
    print(view.safeAreaInsets)
  }

  init(color: UIColor, title: String) {
    super.init(nibName: nil, bundle: nil)
    
    let hostingView = HostingView(ignoringSafeAreaEdges: []) { state in
      ZStack {

        Color.init(color)
//          .edgesIgnoringSafeArea(.all)

        Rectangle()
          .foregroundColor(.clear)
          .border(Color.black, width: 2)
        
        Text(title)
                
      }
    }

    Mondrian.buildSubviews(on: view) {
      
//      VStackBlock {
//        UIView.mock(backgroundColor: .blue, preferredSize: .init(width: 100, height: 100))
//      }
//      .container(respectingSafeAreaEdges: .all)

      ZStackBlock(alignment: .attach(.all)) {
        hostingView
      }
    }

  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  //  struct ContentView: View {
  //
  //    var body: some View {
  //
  //    }
  //
  //  }

}
