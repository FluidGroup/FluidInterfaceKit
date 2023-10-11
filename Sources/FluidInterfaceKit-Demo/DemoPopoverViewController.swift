import CompositionKit
import FluidPopover
import FluidPortal
import MondrianLayout
import SwiftUIHosting
import UIKit
import SwiftUI
import StackScrollView

final class DemoPopoverViewController: UIViewController {

  struct Item: Hashable {
    let id: UUID = .init()
    let offset: CGFloat
  }

  private let listView = StackScrollView()
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

    listView.append(views: [
      Cell(offset: 0),
      Cell(offset: 200),
      Cell(offset: 260),
      Cell(offset: 300),
      Cell(offset: 350),
    ])

  }

  private final class Cell: UIView {

    private var hostingView: FluidPopoverContainerView<SwiftUIHostingView>!

    init(offset: CGFloat) {
      super.init(frame: .null)

      let _contentView = SwiftUIHostingView {
        Button(
          action: {

          },
          label: {
            Text("📱 Content")
              .padding(2)
              .background(RoundedRectangle(cornerRadius: 16).fill(Color.purple))
          }
        )
      }

      let popupHostingView = FluidPopoverContainerView(contentView: _contentView)

      self.hostingView = popupHostingView

      Mondrian.buildSubviews(on: self) {
        ZStackBlock(alignment: .attach(.all)) {
          popupHostingView
            .viewBlock
            .padding(20)
            .padding(.leading, offset)
        }
      }

      let view = hostingView.activate()
      view.addSubviewOnTop(view: tipContent)
    }

    required init?(coder: NSCoder) {
      fatalError()
    }

    let tipContent = SwiftUIHostingView {
      HStack {
        Button("tip") {
          print("tap : tip")
        }
        Text("string")
      }
      .padding(8)
      .background(RoundedRectangle(cornerRadius: 16).fill(Color.red))
    }

  }
}
