import StorybookKit
import SwiftUI
import UIKit

/// Hosts the demo catalog and its UIKit presentation context.
final class RootContainerViewController: UIViewController {

  init() {
    super.init(nibName: nil, bundle: nil)

    let child = UIHostingController(
      rootView: StorybookDisplayRootView(
        bookStore: BookStore(book: book),
        launchRequest: .catalog
      )
    )

    addChild(child)
    view.addSubview(child.view)
    child.view.frame = view.bounds
    child.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    child.didMove(toParent: self)

  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
