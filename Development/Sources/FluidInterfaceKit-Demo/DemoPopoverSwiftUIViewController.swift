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

            PopoverAnchor(
              content: {
                Button(
                  "Hello",
                  action: {

                  }
                )
              }
            ),

          ],
          body: { $0 }
        )

      }

    }

  }
}

/// Hosts a SwiftUI popover anchor in its own UIKit view controller.
///
/// SwiftUI owns the controller's containment and lifetime. Content updates reuse
/// that controller so the anchor keeps its UIKit identity across view updates.
fileprivate struct PopoverAnchor<Content: View>: UIViewControllerRepresentable {

  private let content: Content

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  func makeUIViewController(context: Context) -> UIHostingController<Content> {
    UIHostingController(rootView: content)
  }

  func updateUIViewController(_ uiViewController: UIHostingController<Content>, context: Context) {
    withTransaction(context.transaction) {
      uiViewController.rootView = content
    }
  }
}
