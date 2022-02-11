import FluidInterfaceKit
import ResultBuilderKit
import UIKit

struct Node: Hashable {

  let instance: UIViewController

  let children: [Node]

  init(
    _ instance: UIViewController = UIViewController(),
    @ArrayBuilder<Node> _ build: () -> [Node]
  ) {
    
    self.instance = instance
    self.children = build()
    
    func make(node: Node) {

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
