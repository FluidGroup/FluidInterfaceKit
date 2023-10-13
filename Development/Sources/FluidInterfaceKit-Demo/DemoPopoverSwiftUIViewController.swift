import CompositionKit
import SwiftUI
import SwiftUISupport
import UIKit

final class DemoPopoverSwiftUIViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    let contentView = _View()
    let hostingController = UIHostingController(rootView: contentView)
    hostingController.view.backgroundColor = .clear
    hostingController.view.translatesAutoresizingMaskIntoConstraints = false
    addChild(hostingController)

    view.addSubview(hostingController.view)
    NSLayoutConstraint.activate([
      hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
      hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
    hostingController.didMove(toParent: self)
  }

  struct _View: View {

    var body: some View {

      VStack {

        ForEach.inefficient(
          items: [

            HostingEdge(
              content: {
                Button(
                  "Hello",
                  action: {

                  }
                )
              },
              reference: { hoge in

              }
            ),

          ],
          body: { $0 }
        )

      }

    }

  }
}
