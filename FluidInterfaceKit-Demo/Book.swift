import CompositionKit
import MatchedTransition
import MondrianLayout
import StorybookKit
import UIKit

let book = Book(title: "MyBook") {

  BookPush(title: "Demo") {
    DemoViewController()
  }

  BookNavigationLink(title: "Velocity Playground") {

    BookPush(title: "Scaling") {
      ScalingVelocityPlaygroundViewController()
    }

    BookPush(title: "Translation") {
      TranslationVelocityPlaygroundViewController()
    }
  }

  BookNavigationLink(title: "Transition") {
    BookPush(title: "Adding - in fluid stack") {
      DemoTransitionViewController(usesFluid: true)
    }

    BookPush(title: "Adding - in presentation") {
      DemoTransitionViewController(usesFluid: false)
    }
  }

  BookPresent(title: "Instagram Threads") {
    let controller = DemoThreadsMessagesViewController()
    controller.modalPresentationStyle = .fullScreen
    return controller
  }

  BookPresent(title: "List + ZStack") {
    let controller = DemoListViewController(usesPresentation: false)
    controller.modalPresentationStyle = .fullScreen
    return controller
  }

  BookPresent(title: "List + Presentation") {
    let controller = DemoListViewController(usesPresentation: true)
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

  BookNavigationLink(title: "Experiments") {
    if #available(iOS 15, *) {
      BookPush(title: "ContextMenu") {
        DemoContextMenuViewController()
      }
    }
  }
}
