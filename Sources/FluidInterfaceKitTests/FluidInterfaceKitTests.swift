
import XCTest
import FluidInterfaceKit

final class DismissTests: XCTestCase {
  
  override func setUp() {
    FluidFeatures.enablesDismissalFallback = true
  }

  @MainActor
  func testDismiss() async {
    
    let window = UIWindow()
    
    let rootViewController = UIViewController()
    let stackController = FluidStackController()
    
    window.rootViewController = rootViewController
    window.makeKeyAndVisible()
    
    rootViewController.addChild(stackController)
    rootViewController.view.addSubview(stackController.view)
    stackController.didMove(toParent: stackController)
    
    let fluidPresentation = UIViewController()
    stackController.addContentViewController(fluidPresentation, transition: .noAnimation)
    XCTAssertEqual(stackController.stackingViewControllers.count, 1)
      
    fluidPresentation.fluidPop(transition: .noAnimation, completion: nil)
    XCTAssertEqual(stackController.stackingViewControllers.count, 0)
    
    stackController.present(fluidPresentation)
    
    XCTAssertEqual(fluidPresentation.presentingViewController, rootViewController)
    
    fluidPresentation.fluidPop(transition: .noAnimation, completion: {
    })
    
    XCTAssertEqual(fluidPresentation.presentingViewController, nil)
  }
  
}

extension UIViewController {
  
  @MainActor
  func present(_ viewController: UIViewController) {
    present(viewController, animated: true, completion: {
    })
  }
  
}
