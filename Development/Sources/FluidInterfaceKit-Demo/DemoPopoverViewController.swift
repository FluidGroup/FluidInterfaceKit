import CompositionKit
import FluidTooltipSupport
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
      Cell(offset: 0, isTop: true),
      Cell(offset: 0, isTop: false),

      Cell(offset: 200, isTop: true),
      Cell(offset: 200, isTop: false),

      Cell(offset: 260, isTop: true),
      Cell(offset: 260, isTop: false),

      Cell(offset: 330, isTop: true),
      Cell(offset: 330, isTop: false),

    ])

  }

  private final class Cell: UIView {

    private var hostingView: FluidTooltipContainerView<SwiftUIHostingView>!

    init(offset: CGFloat, isTop: Bool) {
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

      let popupHostingView = FluidTooltipContainerView(contentView: _contentView)

      self.hostingView = popupHostingView

      Mondrian.buildSubviews(on: self) {
        ZStackBlock(alignment: .attach(.all)) {
          popupHostingView
            .viewBlock
            .padding(20)
            .padding(.leading, offset)
        }
      }

      let view = hostingView.tooltipContentView

      if isTop {
        view.addSubviewOnTop(view: tipContent)
      } else {
        view.addSubviewOnBottom(view: tipContent)
      }
      popupHostingView.activate()

      backgroundColor = .systemBackground
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
