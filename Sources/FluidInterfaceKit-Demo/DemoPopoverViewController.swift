import CompositionKit
import FluidPopover
import FluidPortal
import MondrianLayout
import UIKit

final class DemoPopoverViewController: UIViewController {

  private let listView = DynamicCompositionalLayoutView<String, String>(scrollDirection: .vertical)
  private let portalStackView = PortalStackView()

  override func viewDidLoad() {

    super.viewDidLoad()

    view.backgroundColor = .white

    Mondrian.buildSubviews(on: self.view) {

      ZStackBlock(alignment: .attach(.all)) {

        listView

        portalStackView
      }

    }

    listView.registerCell(Cell.self)

    listView.setUp(
      cellProvider: .init({ [portalStackView] context in

        let cell = context.dequeueReusableCell(Cell.self)
        cell.setData(context.data, stack: portalStackView)

        return cell
      }),
      actionHandler: { action in }
    )

    listView.setContents(
      (0..<30).map { $0.description },
      inSection: "A"
    )

  }

  private final class Cell: UICollectionViewCell {

    private let label = UILabel()

    private let button = UIButton(type: .system)

    private var hostingView: FluidPopoverHostingView<AnyUIView>!

    override init(frame: CGRect) {
      super.init(frame: frame)

      contentView.backgroundColor = .white
      label.backgroundColor = .yellow

      let popupHostingView = FluidPopoverHostingView(
        content:
          AnyUIView { _ in
            VStackBlock {
              label
            }
            .padding(20)
          }
      )

      self.hostingView = popupHostingView

      Mondrian.buildSubviews(on: contentView) {
        ZStackBlock(alignment: .attach(.all)) {
          popupHostingView
        }
      }
    }

    required init?(coder: NSCoder) {
      fatalError()
    }

    func setData(_ string: String, stack: PortalStackView) {
      self.label.text = string
      self.button.setTitle(string, for: .normal)

      let r = hostingView.showReparentingView()
      r.backgroundColor = .init(white: 0.5, alpha: 0.5)

//      stack.register(view: button)
    }
  }
}
