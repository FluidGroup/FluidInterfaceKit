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

    let gridView = VGridView(numberOfColumns: 3)

    let makeCell: () -> UIView = {

      let colorBox = UIView()&>.do {
        $0.backgroundColor = .neon(.yellow)
      }

      let interaction = UIContextMenuInteraction(delegate: self)

      let view = AnyView { _ in
        ZStackBlock {
          colorBox
            .viewBlock
            .aspectRatio(1)
            .padding(2)
            .alignSelf(.attach(.all))
        }
      }

      view.clipsToBounds = true
      view.addInteraction(interaction)

      return view
    }

    let cells = (0..<20).map { _ in
      makeCell()
    }

    gridView.setContents(cells)

    Mondrian.buildSubviews(on: view) {
      ZStackBlock {
        gridView.viewBlock.alignSelf(.attach(.all))
      }
    }

  }
}

@available(iOS 15, *)
extension DemoContextMenuViewController: UIContextMenuInteractionDelegate {
  func contextMenuInteraction(
    _ interaction: UIContextMenuInteraction,
    configurationForMenuAtLocation location: CGPoint
  ) -> UIContextMenuConfiguration? {
    
    return UIContextMenuConfiguration(
      identifier: nil,
      previewProvider: {
        DemoListDetailViewController(viewModel: .init(), removingTransitionProvider: { fatalError() })
      },
      actionProvider: {
        suggestedActions in
        let inspectAction =
          UIAction(
            title: NSLocalizedString("InspectTitle", comment: ""),
            image: UIImage(systemName: "arrow.up.square")
          ) { action in

          }

        let duplicateAction =
          UIAction(
            title: NSLocalizedString("DuplicateTitle", comment: ""),
            image: UIImage(systemName: "plus.square.on.square")
          ) { action in

          }

        let deleteAction =
          UIAction(
            title: NSLocalizedString("DeleteTitle", comment: ""),
            image: UIImage(systemName: "trash"),
            attributes: .destructive
          ) { action in

          }

        return UIMenu(title: "", children: [inspectAction, duplicateAction, deleteAction])
      }
    )
  }

}
