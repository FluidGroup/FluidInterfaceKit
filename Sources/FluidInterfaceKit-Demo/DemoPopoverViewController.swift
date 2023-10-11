import CompositionKit
import FluidPopover
import FluidPortal
import MondrianLayout
import SwiftUIHosting
import UIKit
import SwiftUI

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

    private var hostingView: FluidPopoverContainerView<SwiftUIHostingView>!

    override init(frame: CGRect) {
      super.init(frame: frame)

      contentView.backgroundColor = .white
      label.backgroundColor = .yellow

      let _contentView = SwiftUIHostingView {
        Button(
          action: {

          },
          label: {
            Text("📱")
          }
        )
      }

      let popupHostingView = FluidPopoverContainerView(contentView: _contentView)

      self.hostingView = popupHostingView

      Mondrian.buildSubviews(on: contentView) {
        ZStackBlock(alignment: .attach(.all)) {

          popupHostingView
            .viewBlock.padding(20)
        }
      }
    }

    required init?(coder: NSCoder) {
      fatalError()
    }

    func setData(_ string: String, stack: PortalStackView) {
      self.button.setTitle(string, for: .normal)

      let view = hostingView.activate()

      let content = SwiftUIHostingView {
        Text(string)
          .background(Color.purple)
      }

      view.addSubview(content)

      content.translatesAutoresizingMaskIntoConstraints = false

      NSLayoutConstraint.activate([
        content.topAnchor.constraint(equalTo: view.topLayoutGuide.topAnchor),
        content.bottomAnchor.constraint(equalTo: view.topLayoutGuide.bottomAnchor),
        content.leadingAnchor.constraint(equalTo: view.topLayoutGuide.leadingAnchor),
        content.trailingAnchor.constraint(equalTo: view.topLayoutGuide.trailingAnchor),
      ])

    }

  }
}
