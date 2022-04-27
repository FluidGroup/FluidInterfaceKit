
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
  }
}

private final class DetailViewController: CodeBasedViewController {
  
  
}
