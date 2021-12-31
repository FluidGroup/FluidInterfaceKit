import CompositionKit
import FluidInterfaceKit
import MondrianLayout
import StorybookKit
import UIKit

final class DemoListViewController: ZStackViewController {

  private let scrollableContainerView = ScrollableContainerView()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white
    scrollableContainerView.delaysContentTouches = false

    Mondrian.buildSubviews(on: view) {
      ZStackBlock(alignment: .attach(.all)) {
        scrollableContainerView
      }
    }

    let listCells: [UIView] = (0..<20).map { i in
      makeListCell(onTap: { [unowned self] view in

        let controller = DetailViewController()

        let displayViewController = InteractiveDismissalTransitionViewController(
          bodyViewController: controller,
          transition: .init(
            adding: .expanding(from: view),
            removing: nil
          ),
          interaction: .horizontalDragging(backTo: nil, interpolationView: nil, hidingViews: [])
        )

        addContentViewController(displayViewController, transition: nil)

      })
    }

    let content = AnyView { view in

      VStackBlock(alignment: .fill) {
        listCells
      }
      .padding(.horizontal, 24)

    }

    scrollableContainerView.setContent(content)
  }
}

private final class DetailViewController: UIViewController, ViewControllerZStackContentType {

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = BookGenerator.randomColor()

    Mondrian.buildSubviews(on: view) {

      VStackBlock(alignment: .fill) {

        UILabel()&>.do {
          $0.text = "Detail"
          $0.font = UIFont.preferredFont(forTextStyle: .headline)
          $0.textColor = UIColor.appBlack
        }

        StackingSpacer(minLength: 0)

      }
      .padding(.horizontal, 24)
      .respectSafeArea(edges: .all)

    }

  }
}

private func makeListCell(onTap: @escaping (UIView) -> Void) -> UIView {

  let nameLabel = UILabel()&>.do {
    $0.text = "Muukii"
    $0.font = UIFont.preferredFont(forTextStyle: .headline)
    $0.textColor = .black
  }

  let statusLabel = UILabel()&>.do {
    $0.text = "Active now"
    $0.font = UIFont.preferredFont(forTextStyle: .caption1)
    $0.textColor = .darkGray
  }

  let imageView = UIView()&>.do {
    $0
    //    $0.backgroundColor = color
  }

  let backgroundView = UIView()
  backgroundView.backgroundColor = .init(white: 0, alpha: 0.1)
  if #available(iOS 13.0, *) {
    backgroundView.layer.cornerCurve = .continuous
  } else {
    // Fallback on earlier versions
  }
  backgroundView.layer.cornerRadius = 16

  let body = AnyView { _ in

    VStackBlock {

      nameLabel
        .viewBlock
        .spacingBefore(8)

      statusLabel
        .viewBlock
        .spacingBefore(4)
    }
    .padding(.vertical, 8)

  }

  let cell = InteractiveView(
    animation: .shrink(cornerRadius: 8, insets: .zero, overlayColor: .init(white: 0, alpha: 0.1)),
    haptics: .impactOnTouchUpInside(style: .light),
    contentView: body
  )

  cell.handlers.onTap = { [unowned cell] in
    onTap(cell)
  }

  return cell
}
