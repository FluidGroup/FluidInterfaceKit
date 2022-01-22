import CompositionKit
import FluidInterfaceKit
import Foundation
import MondrianLayout
import StorybookKit
import UIKit

@available(iOS 15, *)
final class DemoContextMenuViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground

    var configuration = UIButton.Configuration.bordered()
    configuration.title = "Tap"

    let button = UIButton(
      configuration: configuration,
      primaryAction: .init(handler: { _ in

      })
    )

    button.showsMenuAsPrimaryAction = true

    button.menu = UIMenu.init(
      title: "Title",
      subtitle: "Subtitle",
      image: nil,
      identifier: .init(rawValue: "id"),
      options: [.displayInline],
      children: [
        UIAction(
          title: "Title",
          image: nil,
          identifier: nil,
          discoverabilityTitle: nil,
          attributes: [],
          state: .off,
          handler: { _ in

          }
        )
      ]
    )

    Mondrian.buildSubviews(on: view) {
      ZStackBlock {
        button
      }
    }

  }
}
