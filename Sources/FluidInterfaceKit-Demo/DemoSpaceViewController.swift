
import UIKit
import FluidInterfaceKit
import MondrianLayout
import CompositionKit
import SwiftUI

final class DemoSpaceViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
        
    let spaceViewController = FluidSpaceViewController(viewControllers: [
      ContentViewController(color: .neonRandom(), title: "1"),
      ContentViewController(color: .neonRandom(), title: "2"),
      ContentViewController(color: .neonRandom(), title: "3"),
    ])
    
    addChild(spaceViewController)
    
    Mondrian.buildSubviews(on: view) {
      
      ZStackBlock(alignment: .attach(.all)) {
        spaceViewController.view
      }
    }
    
    spaceViewController.didMove(toParent: self)
    
  }
}

fileprivate final class ContentViewController: UIViewController {
      
  init(color: UIColor, title: String) {
    super.init(nibName: nil, bundle: nil)
        
    let hostingView = HostingView { state in
      ZStack {
        
        Color.init(color).edgesIgnoringSafeArea(.all)
        
        Text(title)
      }
    }

    Mondrian.buildSubviews(on: view) {
      
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
