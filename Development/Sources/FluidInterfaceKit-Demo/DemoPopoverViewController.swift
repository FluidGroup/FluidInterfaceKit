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

public final class FluidTooltipContainerView<ContentView: UIView>: UIView {

  public let contentView: ContentView

  public var tooltipContentView: FluidTooltipContentView {
    hostingView.contentView
  }

  public let hostingView: FluidTooltipHostingView = .init()

  public init(contentView: ContentView) {
    self.contentView = contentView

    super.init(frame: .null)

    addSubview(contentView)
    contentView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      contentView.topAnchor.constraint(equalTo: topAnchor),
      contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
      contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])

  }

  public func activate() {
    insertSubview(hostingView, at: 0)

    hostingView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      hostingView.topAnchor.constraint(equalTo: topAnchor),
      hostingView.bottomAnchor.constraint(equalTo: bottomAnchor),
      hostingView.leadingAnchor.constraint(equalTo: leadingAnchor),
      hostingView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])

  }

  public func deactivate() {
    hostingView.removeFromSuperview()
  }

  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}
