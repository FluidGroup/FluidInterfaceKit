import StorybookKit
import MondrianLayout
import CompositionKit
import UIKit
import MatchedTransition

let book = Book(title: "MyBook") {

  BookPush(title: "Demo") {
    DemoViewController()
  }

  BookPush(title: "VelocityPlayground") {
    VelocityPlaygroundViewController()
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

  BookPush(title: "AnimatorPlayground") {
    AnimatorPlaygroundViewController()
  }

}
