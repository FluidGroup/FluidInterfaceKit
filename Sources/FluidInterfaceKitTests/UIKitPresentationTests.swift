
import XCTest

final class UIKitPresentationTests: XCTestCase {
  
  func testPresentation() {
    
    let window = UIWindow()
    window.isHidden = false
    
    let root = UIViewController()
    
    window.rootViewController = root
    
    let controller = Controller()
    root.present(controller, animated: true)
            
    XCTAssertNotNil(controller.presentingViewController)
  }
}

private final class Controller: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let another = AnotherController()
    present(another, animated: true)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
}

private final class AnotherController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
}
