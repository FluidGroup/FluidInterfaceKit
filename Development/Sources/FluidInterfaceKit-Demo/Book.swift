import CompositionKit
import MondrianLayout
import StorybookKit
import UIKit
import FluidStack
import FluidPictureInPicture

@MainActor
let book = Book(title: "FluidInterfaceKit") {

  BookCallout(
    symbol: "💡",
    text: """
      This is a demo application to see FluidInterfaceKit.
      """
  )

  BookNavigationLink(title: "Velocity Playground") {

    BookPush(title: "Scaling") {
      ScalingVelocityPlaygroundViewController()
    }

    BookPush(title: "Translation") {
      TranslationVelocityPlaygroundViewController()
    }
  }

  BookNavigationLink(title: "Transition") {
    BookPresent(title: "Adding - in fluid stack") {
      DemoTransitionViewController()
    }
  }

  BookNavigationLink(title: "App") {
    BookPresent(title: "Launch") {
      let controller = DemoApplicationController()
      controller.modalPresentationStyle = .fullScreen
      return controller
    }

  }

  BookNavigationLink(title: "Draggable View") {
    BookPush(title: "Draggable View") {
      DemoDragViewController()
    }
  }

  BookNavigationLink(title: "Experiments") {
    if #available(iOS 15, *) {
      BookPush(title: "ContextMenu") {
        DemoContextMenuViewController()
      }
    }
  }

  BookNavigationLink(title: "PiP") {
    BookPush(title: "Push") {
      DemoPictureInPictureController()
    }
    BookPush(title: "Push - Cool") {
      DemoPictureInPictureCoolController()
    }
  }

  BookPush(title: "SafeArea") {
    DemoSafeAreaViewController()
  }

  BookPush(title: "ControlCenter") {
    DemoControlCenterViewController()
  }

  BookPush(title: "AnimatorPlayground") {
    AnimatorPlaygroundViewController()
  }

  BookPresent(title: "Instagram Threads") {
    let controller = DemoThreadsMessagesViewController()
    controller.modalPresentationStyle = .fullScreen
    return controller
  }

  BookPresent(title: "List + ZStack") {
    let controller = DemoListContainerViewController()
    controller.modalPresentationStyle = .fullScreen
    return controller
  }
  
  BookPresent(title: "+ Rideau") {
    let controller = DemoRideauIntegrationViewController()
    controller.modalPresentationStyle = .fullScreen
    return controller
  }
  
  BookPresent(title: "Sheet") {
    let controller = DemoSheetViewController()
    controller.modalPresentationStyle = .fullScreen
    return controller
  }

  BookPresent(title: "Stacking") {
    let controller = DemoStackingViewController()
    controller.modalPresentationStyle = .fullScreen
    return controller
  }
  
  BookPush(title: "CAPortalLayer") {
    DemoPortalLayerViewController()
  }

  BookPush(title: "PortalStackView") {
    DemoPortalStackViewController()
  }

  BookPush(title: "Popover SwiftUI") {
    DemoPopoverSwiftUIViewController()
  }

  BookPush(title: "Popover UIKit") {
    DemoPopoverViewController()
  }

  BookPush(title: "Composition") {
    DemoCompositionOrderViewController()
  }

  BookPush(title: "FloatingDisplayKit") {
    DemoFloatingDisplayKit(rootView: .init())
  }

  if #available(iOS 15, *) {
    BookPush(title: "KeyboardLayoutGuide") {
      DemoKeyboardGuideViewController()
    }
  }

  BookPush(title: "StageViewController") {
    DemoStageViewController()
  }

  BookNavigationLink(title: "iOS 14 Pickers") {
    
    BookPreview(expandsWidth: true, maxHeight: 400, minHeight: 400) {
      UIView()&>.do {
        $0.backgroundColor = .white
      }
    }
  
    BookSection(title: "Time picker .compact") {
      BookPreview {
        let datePicker = UIDatePicker()
        datePicker.date = Date()
        if #available(iOS 13.4, *) {
          datePicker.preferredDatePickerStyle = .compact
        } else {
          // Fallback on earlier versions
        }
        datePicker.calendar = Calendar(identifier: .japanese)
        datePicker.datePickerMode = .time

        return datePicker
      }
    }
    
    BookPreview(expandsWidth: true, maxHeight: 800, minHeight: 800) {
      UIView()&>.do {
        $0.backgroundColor = .white
      }
    }

  }

}

@MainActor
func makeButtonView(title: String, onTap: @escaping () -> Void) -> UIView {
  let button = UIButton(type: .system)
  button.setTitle(title, for: .normal)
  button.onTap {
    onTap()
  }

  return AnyUIView { _ in
    VStackBlock {
      button
    }
    .padding(10)
  }
}
