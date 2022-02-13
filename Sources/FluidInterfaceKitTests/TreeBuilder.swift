import FluidInterfaceKit
import ResultBuilderKit
import UIKit

public struct VC: Hashable {

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

        let parent = node.instance
        if let stack = parent as? FluidStackController {
          stack.addContentViewController(child.instance, transition: .noAnimation)
        } else {
          parent.addChild(child.instance)
          parent.view.addSubview(child.instance.view)
          child.instance.view.frame = parent.view.bounds
          child.instance.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
          child.instance.didMove(toParent: parent)
        }

      }

    }

    make(node: self)

  }

}

struct ComparisonResult {
  
  struct Condition {
    let description: String
    let result: Bool
  }
  
  var conditions: [Condition] = []
  
  var result: Bool {
    conditions.allSatisfy { $0.result == true }
  }
  
}

struct ViewControllerRep {

  let pointer: Unmanaged<UIViewController>?

  let view: ViewRep

  let children: [ViewControllerRep]

  init(
    pointer:  Unmanaged<UIViewController>?,
    view: ViewRep,
    @ArrayBuilder<ViewControllerRep> children: () -> [ViewControllerRep]
  ) {
    self.pointer = pointer
    self.view = view
    self.children = children()
  }
  
  func compare(expectation: ViewControllerRep) -> ComparisonResult {
    var result: ComparisonResult = .init()
    compare(expectation: expectation, result: &result)
    return result
  }
  
  func compare(expectation: ViewControllerRep, result: inout ComparisonResult) {
                
    if let expectedPointer = expectation.pointer {
      result.conditions.append(
        .init(
          description: "Expects pointer \(expectedPointer)",
          result: pointer?.toOpaque() == expectedPointer.toOpaque()
        )
      )
    }
    
    if let expectedViewPointer = expectation.view.pointer {
      result.conditions.append(
        .init(
          description: "Expects pointer \(expectedViewPointer)",
          result: view.pointer?.toOpaque() == expectedViewPointer.toOpaque()
        )
      )
    }
    
    if children.count == expectation.children.count {
      
      zip(children, expectation.children).forEach { child, expectedChild in
        child.compare(expectation: expectedChild, result: &result)
      }
      
    } else {
      
      result.conditions.append(
        .init(
          description: "Compare: children count",
          result: false
        )
      )
      
    }
                  
    view.compare(expectation: expectation.view, result: &result)
    
  }

}

struct ViewRep {

  let pointer: Unmanaged<UIView>?

  let subviews: [ViewRep]

  init(pointer: Unmanaged<UIView>?, @ArrayBuilder<ViewRep> subviews: () -> [ViewRep]) {
    self.pointer = pointer
    self.subviews = subviews()
  }
  
  func compare(expectation: ViewRep) -> ComparisonResult {
    var result: ComparisonResult = .init()
    compare(expectation: expectation, result: &result)
    return result
  }
  
  func compare(expectation: ViewRep, result: inout ComparisonResult) {
    
    if let expectedPointer = expectation.pointer {
      result.conditions.append(
        .init(
          description: "Expects pointer \(expectedPointer)",
          result: pointer?.toOpaque() == expectedPointer.toOpaque()
        )
      )
    }
        
    if subviews.count == expectation.subviews.count {
      
      zip(subviews, expectation.subviews).forEach { child, expectedChild in
        child.compare(expectation: expectedChild, result: &result)
      }
      
    } else {
      
      result.conditions.append(
        .init(
          description: "Compare: subviews count",
          result: false
        )
      )
      
    }
    
  }

}

extension UIViewController {

  func makeRepresentation() -> ViewControllerRep {
    
    ViewControllerRep(
      pointer: Unmanaged.passUnretained(self),
      view: view.makeRepresentation(),
      children: { children.map { $0.makeRepresentation() } }
    )

  }

}

extension UIView {
  func makeRepresentation() -> ViewRep {
    ViewRep(
      pointer: Unmanaged.passUnretained(self),
      subviews: { subviews.map { $0.makeRepresentation() } }
    )
  }
}
