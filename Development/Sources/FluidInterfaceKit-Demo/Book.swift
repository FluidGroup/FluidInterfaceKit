import CompositionKit
import MondrianLayout
import StorybookKit
import SwiftUI
import UIKit
import FluidStack
import FluidPictureInPicture

/// The demo pages registered with Storybook's catalog, search, and history.
@MainActor
let book = Book(title: "FluidInterfaceKit") {

  BookPage(title: "About") {
    BookText("💡 This is a demo application to see FluidInterfaceKit.")
  }

  Book(title: "Velocity Playground") {

    BookPage(title: "Scaling", usesScrollView: false) {
      DemoControllerPreview { ScalingVelocityPlaygroundViewController() }
    }

    BookPage(title: "Translation", usesScrollView: false) {
      DemoControllerPreview { TranslationVelocityPlaygroundViewController() }
    }
  }

  Book(title: "Transition") {
    BookPage(title: "Adding - in fluid stack") {
      BookPresent(title: "Adding - in fluid stack") {
        DemoTransitionViewController()
      }
    }
  }

  Book(title: "App") {
    BookPage(title: "Launch") {
      BookPresent(title: "Launch") {
        let controller = DemoApplicationController()
        controller.modalPresentationStyle = .fullScreen
        return controller
      }
    }

  }

  Book(title: "Draggable View") {
    BookPage(title: "Draggable View", usesScrollView: false) {
      DemoControllerPreview { DemoDragViewController() }
    }
  }

  Book(title: "Experiments") {
    if #available(iOS 15, *) {
      BookPage(title: "ContextMenu", usesScrollView: false) {
        DemoControllerPreview { DemoContextMenuViewController() }
      }
    }
  }

  Book(title: "PiP") {
    BookPage(title: "Push", usesScrollView: false) {
      DemoControllerPreview { DemoPictureInPictureController() }
    }
    BookPage(title: "Push - Cool", usesScrollView: false) {
      DemoControllerPreview { DemoPictureInPictureCoolController() }
    }
  }

  BookPage(title: "SafeArea", usesScrollView: false) {
    DemoControllerPreview { DemoSafeAreaViewController() }
  }

  BookPage(title: "ControlCenter", usesScrollView: false) {
    DemoControllerPreview { DemoControlCenterViewController() }
  }

  BookPage(title: "AnimatorPlayground", usesScrollView: false) {
    DemoControllerPreview { AnimatorPlaygroundViewController() }
  }

  BookPage(title: "Instagram Threads") {
    BookPresent(title: "Instagram Threads") {
      let controller = DemoThreadsMessagesViewController()
      controller.modalPresentationStyle = .fullScreen
      return controller
    }
  }

  BookPage(title: "List + ZStack") {
    BookPresent(title: "List + ZStack") {
      let controller = DemoListContainerViewController()
      controller.modalPresentationStyle = .fullScreen
      return controller
    }
  }
  
  BookPage(title: "+ Rideau") {
    BookPresent(title: "+ Rideau") {
      let controller = DemoRideauIntegrationViewController()
      controller.modalPresentationStyle = .fullScreen
      return controller
    }
  }
  
  BookPage(title: "Sheet") {
    BookPresent(title: "Sheet") {
      let controller = DemoSheetViewController()
      controller.modalPresentationStyle = .fullScreen
      return controller
    }
  }

  BookPage(title: "Stacking") {
    BookPresent(title: "Stacking") {
      let controller = DemoStackingViewController()
      controller.modalPresentationStyle = .fullScreen
      return controller
    }
  }
  
  BookPage(title: "CAPortalLayer", usesScrollView: false) {
    DemoControllerPreview { DemoPortalLayerViewController() }
  }

  BookPage(title: "PortalStackView", usesScrollView: false) {
    DemoControllerPreview { DemoPortalStackViewController() }
  }

  BookPage(title: "Popover SwiftUI", usesScrollView: false) {
    DemoControllerPreview { DemoPopoverSwiftUIViewController() }
  }

  BookPage(title: "Popover UIKit", usesScrollView: false) {
    DemoControllerPreview { DemoPopoverViewController() }
  }

  BookPage(title: "Composition", usesScrollView: false) {
    DemoControllerPreview { DemoCompositionOrderViewController() }
  }

  BookPage(title: "FloatingDisplayKit", usesScrollView: false) {
    DemoControllerPreview { DemoFloatingDisplayKit(rootView: .init()) }
  }

  if #available(iOS 15, *) {
    BookPage(title: "KeyboardLayoutGuide", usesScrollView: false) {
      DemoControllerPreview { DemoKeyboardGuideViewController() }
    }
  }

  BookPage(title: "StageViewController", usesScrollView: false) {
    DemoControllerPreview { DemoStageViewController() }
  }

  BookPage(title: "iOS 14 Pickers") {
    
    BookPreview { _ in
      UIView()&>.do {
        $0.backgroundColor = .white
      }
    }
    .previewFrame(maxWidth: .infinity, minHeight: 400, idealHeight: 400, maxHeight: 400)
  
    BookSection(title: "Time picker .compact") {
      BookPreview { _ in
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
    
    BookPreview { _ in
      UIView()&>.do {
        $0.backgroundColor = .white
      }
    }
    .previewFrame(maxWidth: .infinity, minHeight: 800, idealHeight: 800, maxHeight: 800)

  }

}

/// Embeds a UIKit demo directly in a Storybook page without another launch link.
///
/// SwiftUI owns containment and keeps the controller alive for the page's
/// lifetime. The factory runs only when SwiftUI creates the represented controller.
fileprivate struct DemoControllerPreview<Controller: UIViewController>: UIViewControllerRepresentable {

  let makeController: @MainActor () -> Controller

  func makeUIViewController(context: Context) -> Controller {
    makeController()
  }

  func updateUIViewController(_ uiViewController: Controller, context: Context) {
    // These demos own their state; view updates must not replace their controller.
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
