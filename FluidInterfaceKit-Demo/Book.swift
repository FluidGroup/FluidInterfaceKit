import StorybookKit
import MondrianLayout
import CompositionKit
import UIKit
import MatchedTransition

let book = Book(title: "MyBook") {

  BookPreview {
    UIView()
  }
  .addButton("Debug On") { _ in
    _matchedTransition_setIsAnimationDebugModeEnabled(true)
  }
  .addButton("Debug Off") { _ in
    _matchedTransition_setIsAnimationDebugModeEnabled(false)
  }

  BookPush(title: "Demo") {
    DemoViewController()
  }
  BookPresent(title: "Instagram Threads") {
    let controller = DemoThreadsMessagesViewController()
    controller.modalPresentationStyle = .fullScreen
    return controller
  }
  BookPush(title: "ControlCenter") {
    DemoControlCenterViewController()
  }

  BookPush(title: "Presentation") {
    DemoPresentationViewController()
  }

}
