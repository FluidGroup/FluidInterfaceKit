import CompositionKit
import FluidPortal
import MondrianLayout
import UIKit

final class DemoPortalStackViewController: UIViewController {

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
      [
        "1",
        "2",
        "3",
        "4",
        "5",
        "6",
        "7",
        "8",
      ],
      inSection: "A"
    )

  }

  private final class Cell: UICollectionViewCell {

    private let label = UILabel()

    private let button = UIButton(type: .system)

    override init(frame: CGRect) {
      super.init(frame: frame)

      contentView.backgroundColor = .white

      Mondrian.buildSubviews(on: contentView) {
        VStackBlock {
          label
        }
        .padding(20)
        .overlay(button.viewBlock
          .padding(.top, 50)
          .padding(.bottom, -50)
        )
      }
    }

    required init?(coder: NSCoder) {
      fatalError()
    }

    func setData(_ string: String, stack: PortalStackView) {
      self.label.text = string
      self.button.setTitle(string, for: .normal)
      stack.register(view: button)
    }
  }
}
