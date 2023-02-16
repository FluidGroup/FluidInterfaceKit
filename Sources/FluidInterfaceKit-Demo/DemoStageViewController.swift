import CompositionKit
import FluidInterfaceKit
import MondrianLayout
import SwiftUI
import UIKit

final class DemoStageViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    let spaceViewController = FluidStageViewController(
      leftSideViewController: ContentViewController(color: .neonRandom(), title: "left"),
      mainViewController: ContentViewController(color: .neonRandom(), title: "main"),
      rightSideViewController: ContentViewController(color: .neonRandom(), title: "right"),
      actionHandler: { action in
        print(action)
      }
    )

    addChild(spaceViewController)
    
    let controlView = HostingView(ignoringSafeAreaEdges: []) { [spaceViewController] state in
      
      HStack {
        Button("Left") {
          spaceViewController.select(stage: .left, animated: true)
        }
        Button("Main") {
          spaceViewController.select(stage: .main, animated: true)
        }
        Button("Right") {
          spaceViewController.select(stage: .right, animated: true)
        }
      }
      
    }
    
    Mondrian.buildSubviews(on: view) {

      VStackBlock {
        
        spaceViewController.view.viewBlock.alignSelf(.fill)
                
        controlView.viewBlock
          .height(200)
          .alignSelf(.fill)
      }
    }

    spaceViewController.didMove(toParent: self)

  }
}

private final class ContentViewController: UIViewController, FluidStageChildViewController {
  
  override func viewSafeAreaInsetsDidChange() {
    super.viewSafeAreaInsetsDidChange()
    
    print(view.safeAreaInsets)
  }
  
  private let color: UIColor
  private let _title: String

  init(color: UIColor, title: String) {
    
    self.color = color
    self._title = title
    
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
  
  func didSelect(_ stageViewController: FluidStageViewController) {
    print("title: \(_title)")
  }

}
