import CompositionKit
import FluidStack
import Foundation
import MondrianLayout
import StorybookKit
import UIKit

@available(iOS 15, *)
final class DemoContextMenuViewController: FluidStackController {

  init() {
    super.init(configuration: .init(retainsRootViewController: false))
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground

    let gridView = VGridView(numberOfColumns: 3)

    let makeCell: () -> UIView = {

      let colorBox = UIView()&>.do {
        $0.backgroundColor = .neon(.yellow)
      }

      let interaction = StandaloneContextMenuInteraction.init(
        entryViewController: self,
        targetStackController: .current,
        destinationViewController: {
          DemoListDetailViewController(
            viewModel: .init(),
            removingTransitionProvider: { .vanishing }
          )
          .fluidWrapped(configuration: .init(transition: .empty, topBar: .hidden))
        }
      )

      let view = AnyUIView { _ in
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

    Mondrian.buildSubviews(on: contentView) {
      ZStackBlock {
        gridView.viewBlock.alignSelf(.attach(.all))
      }
    }

  }
}
