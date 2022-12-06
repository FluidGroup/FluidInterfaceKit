
import UIKit
import FluidInterfaceKit
import MondrianLayout

final class DemoSpaceViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
        
    let spaceViewController = FluidSpaceViewController(viewControllers: [
      ContentViewController(color: .neonRandom()),
      ContentViewController(color: .neonRandom()),
      ContentViewController(color: .neonRandom()),
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
      
  init(color: UIColor) {
    super.init(nibName: nil, bundle: nil)
    
    view.backgroundColor = color
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
