import FluidInterfaceKit
import ResultBuilderKit
import UIKit

struct VC: Hashable {

  let instance: UIViewController

  let children: [VC]

  init(
    _ instance: UIViewController = UIViewController(),
    @ArrayBuilder<VC> _ build: () -> [VC]
  ) {
    
    self.instance = instance
    self.children = build()
    
    func make(node: VC) {

      for child in node.children {
        
        make(node: child)
        
        let parent = node.instance
        if let stack = parent as? FluidStackController {
          stack.addContentViewController(child.instance, transition: .noAnimation)
        } else {
          parent.addChild(child.instance)
          parent.view.addSubview(child.instance.view)
          child.instance.didMove(toParent: parent)
        }
        
      }

    }
    
    make(node: self)
    
  }

}
