import CompositionKit
import MatchedTransition
import MondrianLayout
import StorybookKit
import UIKit

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
    BookPush(title: "Adding - in fluid stack") {
      DemoTransitionViewController(usesFluid: true)
    }

    BookPush(title: "Adding - in presentation") {
      DemoTransitionViewController(usesFluid: false)
    }
  }

  BookNavigationLink(title: "App") {
    BookPresent(title: "Launch") {
      let controller = DemoApplicationController()
      controller.modalPresentationStyle = .fullScreen
      return controller
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
  }

  BookPush(title: "SafeArea") {
    DemoSafeAreaViewController()
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
  
  BookPresent(title: "+ Rideau") {
    let controller = DemoRideauIntegrationViewController()
    controller.modalPresentationStyle = .fullScreen
    return controller
  }

  BookPresent(title: "Stack") {
    let controller = DemoViewController()
    controller.modalPresentationStyle = .fullScreen
    return controller
  }
  
  BookPush(title: "CAPortalLayer") {
    DemoPortalLayerViewController()
  }

  BookNavigationLink(title: "iOS 14 Pickers") {
    BookSection(title: "Date picker .inline") {
      BookPreview {
        let datePicker = UIDatePicker()
        datePicker.date = Date()
        if #available(iOS 14.0, *) {
          datePicker.preferredDatePickerStyle = .inline
        } else {
          // Fallback on earlier versions
        }
        datePicker.calendar = Calendar(identifier: .japanese)
        datePicker.datePickerMode = .date

        return datePicker
      }
    }

    BookSection(title: "Date picker .compact") {
      BookPreview {
        let datePicker = UIDatePicker()
        datePicker.date = Date()
        if #available(iOS 13.4, *) {
          datePicker.preferredDatePickerStyle = .compact
        } else {
          // Fallback on earlier versions
        }
        datePicker.calendar = Calendar(identifier: .japanese)
        datePicker.datePickerMode = .date

        return datePicker
      }
    }

    BookSection(title: "Date picker .wheels") {
      BookPreview {
        let datePicker = UIDatePicker()
        datePicker.date = Date()
        if #available(iOS 13.4, *) {
          datePicker.preferredDatePickerStyle = .wheels
        } else {
          // Fallback on earlier versions
        }
        datePicker.calendar = Calendar(identifier: .japanese)
        datePicker.datePickerMode = .date

        return datePicker
      }
    }

    BookSection(title: "Time picker .inline") {
      BookPreview {
        let datePicker = UIDatePicker()
        datePicker.date = Date()
        if #available(iOS 14.0, *) {
          datePicker.preferredDatePickerStyle = .inline
        } else {
          // Fallback on earlier versions
        }
        datePicker.calendar = Calendar(identifier: .japanese)
        datePicker.datePickerMode = .time

        return datePicker
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

    BookSection(title: "Time picker .wheels") {
      BookPreview {
        let datePicker = UIDatePicker()
        datePicker.date = Date()
        if #available(iOS 13.4, *) {
          datePicker.preferredDatePickerStyle = .wheels
        } else {
          // Fallback on earlier versions
        }
        datePicker.calendar = Calendar(identifier: .japanese)
        datePicker.datePickerMode = .time

        return datePicker
      }
    }

    BookSection(title: "Date and time picker .inline") {
      BookPreview {
        let datePicker = UIDatePicker()
        datePicker.date = Date()
        if #available(iOS 14.0, *) {
          datePicker.preferredDatePickerStyle = .inline
        } else {
          // Fallback on earlier versions
        }
        datePicker.calendar = Calendar(identifier: .japanese)
        datePicker.datePickerMode = .dateAndTime

        return datePicker
      }
    }

    BookSection(title: "Date and time picker .compact") {
      BookPreview {
        let datePicker = UIDatePicker()
        datePicker.date = Date()
        if #available(iOS 13.4, *) {
          datePicker.preferredDatePickerStyle = .compact
        } else {
          // Fallback on earlier versions
        }
        datePicker.calendar = Calendar(identifier: .japanese)
        datePicker.datePickerMode = .dateAndTime

        return datePicker
      }
    }

    BookSection(title: "Date and time picker .wheels") {
      BookPreview {
        let datePicker = UIDatePicker()
        datePicker.date = Date()
        if #available(iOS 13.4, *) {
          datePicker.preferredDatePickerStyle = .wheels
        } else {
          // Fallback on earlier versions
        }
        datePicker.calendar = Calendar(identifier: .japanese)
        datePicker.datePickerMode = .dateAndTime

        return datePicker
      }
    }

    BookSection(
      title: "Count down timer picker (.countDownTimer doesn't support .compact and .inline)"
    ) {
      BookPreview {
        let datePicker = UIDatePicker()
        datePicker.date = Date()
        if #available(iOS 14.0, *) {
          datePicker.preferredDatePickerStyle = .wheels
        } else {
          // Fallback on earlier versions
        }
        datePicker.calendar = Calendar(identifier: .japanese)
        datePicker.datePickerMode = .countDownTimer

        return datePicker
      }
    }
  }

}

func makeButtonView(title: String, onTap: @escaping () -> Void) -> UIView {
  let button = UIButton(type: .system)
  button.setTitle(title, for: .normal)
  button.onTap {
    onTap()
  }

  return AnyView { _ in
    VStackBlock {
      button
    }
    .padding(10)
  }
}
