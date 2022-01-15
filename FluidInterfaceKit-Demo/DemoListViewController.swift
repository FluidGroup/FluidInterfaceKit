import CompositionKit
import FluidInterfaceKit
import MondrianLayout
import StorybookKit
import UIKit

final class DemoListViewController: FluidStackController {

  private let scrollableContainerView = ScrollableContainerView()

  let usesPresentation: Bool

  init(
    usesPresentation: Bool
  ) {
    self.usesPresentation = usesPresentation
    super.init(view: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground
    scrollableContainerView.delaysContentTouches = false

    var viewControllerCache: [Int: ViewControllerFluidContentType] = [:]

    let listCells: [UIView] = (0..<40).map { i in

      let viewModel = ViewModel()

      return makeListCell(
        viewModel: viewModel,
        onTap: { [unowned self] view in

          if let cached = viewControllerCache[i] {

            if usesPresentation {
              present(cached, animated: false, completion: nil)
            } else {
              addContentViewController(cached, transition: nil)
            }

          } else {
            let controller = DetailViewController(viewModel: viewModel)

            let displayViewController = FluidViewController(
              bodyViewController: controller,
              transition: .init(
                adding: .contextualExpanding(from: view, hidingViews: [view]),
                removing: nil
              ),
              interactionToRemove: .horizontalDragging(
                backwardingMode: .shape(destinationView: view),
                hidingViews: [view]
              )
            )

            viewControllerCache[i] = displayViewController

            if usesPresentation {
              present(displayViewController, animated: false, completion: nil)
            } else {
              addContentViewController(displayViewController, transition: nil)
            }
          }

        }
      )
    }

    let content = AnyView { view in

      VGridBlock(
        columns: [
          .init(.flexible(), spacing: 8),
          .init(.flexible(), spacing: 8),
        ],
        spacing: 8
      ) {
        listCells
      }
      .padding(.horizontal, 32)

    }

    scrollableContainerView.setContent(content)

    Mondrian.buildSubviews(on: view) {
      ZStackBlock(alignment: .attach(.all)) {
        scrollableContainerView
      }
    }

  }
}

private final class DetailViewController: UIViewController, ViewControllerFluidContentType {

  private let viewModel: ViewModel

  public init(
    viewModel: ViewModel
  ) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  required init?(
    coder: NSCoder
  ) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground

    Mondrian.buildSubviews(on: view) {

      VStackBlock(alignment: .fill) {

        UILabel()&>.do {
          $0.text = "Detail"
          $0.font = UIFont.preferredFont(forTextStyle: .headline)
          $0.textColor = UIColor.appBlack
        }

        UIView()&>.do {
          $0.backgroundColor = viewModel.color
        }
        .viewBlock
        .aspectRatio(1)
        .spacingBefore(8)

        StackingSpacer(minLength: 0)

      }
      .padding(.horizontal, 24)
      .container(respectingSafeAreaEdges: .all)

    }

  }
}

private func makeListCell(viewModel: ViewModel, onTap: @escaping (UIView) -> Void) -> UIView {

  let nameLabel = UILabel()&>.do {
    $0.text = "Muukii"
    $0.font = UIFont.preferredFont(forTextStyle: .headline)
    $0.textColor = .label
  }

  let statusLabel = UILabel()&>.do {
    $0.text = "Active now"
    $0.font = UIFont.preferredFont(forTextStyle: .caption1)
    $0.textColor = .secondaryLabel
  }

  let imageView = StyledEdgeView(
    cornerRadius: .radius(6),
    cornerRoundingStrategy: .mask,
    content: UIView()&>.do {
      $0.backgroundColor = viewModel.color
    }
  )

  let backgroundView = UIView()
  backgroundView.backgroundColor = .init(white: 0, alpha: 0.1)
  if #available(iOS 13.0, *) {
    backgroundView.layer.cornerCurve = .continuous
  } else {
    // Fallback on earlier versions
  }
  backgroundView.layer.cornerRadius = 16

  let body = AnyView { _ in

    HStackBlock {

      imageView
        .viewBlock
        .size(55)

      VStackBlock(alignment: .leading) {

        nameLabel
          .viewBlock
          .spacingBefore(8)

        statusLabel
          .viewBlock
          .spacingBefore(4)
      }
      .spacingBefore(8)
    }
    .padding(.vertical, 8)

  }

  let cell = InteractiveView(
    animation: .shrink(
      cornerRadius: 8,
      insets: .init(top: 4, left: 16, bottom: 4, right: 16),
      overlayColor: .init(white: 0, alpha: 0.1)
    ),
    haptics: .impactOnTouchUpInside(style: .light),
    contentView: body
  )

  cell.handlers.onTap = { [unowned cell] in
    onTap(cell)
  }

  return cell
}
