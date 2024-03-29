import CompositionKit
import FluidStack
import MondrianLayout
import StorybookKit
import UIKit

final class DemoListContainerViewController: FluidStackController {

  init() {
    super.init(configuration: .init(isOffloadViewsEnabled: true))
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let rootViewController = DemoListViewController()
    
    addContentViewController(rootViewController, transition: .disabled)

  }
}

final class DemoListViewController: UIViewController {

  private let scrollableContainerView = ScrollableContainerView()

  init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground
    scrollableContainerView.delaysContentTouches = false

    var viewControllerCache: [Int: FluidViewController] = [:]

    let listCells: [UIView] = (0..<20).map { i in

      let viewModel = ViewModel()

      return makeListCell(
        viewModel: viewModel,
        onTap: { [unowned self] view in

          if let cached = viewControllerCache[i] {

            fluidPush(cached, target: .current, relation: .hierarchicalNavigation, transition: nil)

          } else {
                        
            let controller = DemoListDetailViewController(
              viewModel: viewModel,
              removingTransitionProvider: {
                .contextual(destinationComponent: view)
              }
            )
            
            let displayViewController = FluidViewController(
              content: .init(bodyViewController: controller),
              configuration: .init(
                transition: .init(
                  addingTransition: .contextualExpanding(
                    from: view
                  ),
                  removingTransition: nil,
                  removingInteraction: .horizontalDragging(
                    backwarding: {
                      .enclosing(to: view)
                    }
                  )
                ),
                topBar: .navigation
              )
            )
            
            viewControllerCache[i] = displayViewController

            fluidPush(displayViewController, target: .current, relation: .hierarchicalNavigation, transition: nil)

          }

        }
      )
    }

    let content = AnyUIView { view in
      
      VStackBlock(alignment: .fill) {
        
        UIButton.make(title: "Open") { [unowned self] in
          let nextController = DemoListViewController()
          
          let wrapped = nextController.fluidWrapped(configuration: .defaultNavigation)
          
          wrapped.removingInteraction = .leftToRightOnScreen
          
          fluidPush(wrapped, target: .current, relation: nil)
        }
        
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
      
    }

    scrollableContainerView.setContent(content)

    Mondrian.buildSubviews(on: view) {
      ZStackBlock(alignment: .attach(.all)) {
        scrollableContainerView
      }
    }

  }
}


final class DemoListDetailViewController: UIViewController {

  private let viewModel: ViewModel
  private let removingTransitionProvider: () -> AnyRemovingTransition

  public init(
    viewModel: ViewModel,
    removingTransitionProvider: @escaping () -> AnyRemovingTransition
  ) {
    
    self.viewModel = viewModel
    self.removingTransitionProvider = removingTransitionProvider
    
    super.init(nibName: nil, bundle: nil)

    title = "Title"
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

      VStackBlock(spacing: 16, alignment: .fill) {

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
        
        UIButton.make(title: "Dismiss") { [unowned self] in
          fluidPop(
            transition: removingTransitionProvider(),
            completion: nil
          )
        }
           
        StackingSpacer(minLength: 0)

      }
      .padding(.vertical, 16)
      .padding(.horizontal, 24)
      .container(respectingSafeAreaEdges: .all)

    }

  }
}

@MainActor
private func makeListCell(viewModel: ViewModel, onTap: @escaping (ContextualTransitionSourceView) -> Void) -> ContextualTransitionSourceView {

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

  let body = AnyUIView { _ in

    VStackBlock {

      imageView
        .viewBlock
        .size(55)
      
      StackingSpacer(minLength: 8, expands: false)
                
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
    onTap(cell.superview as! ContextualTransitionSourceView)
  }
  
  cell.backgroundColor = .init(white: 0.5, alpha: 0.3)
  
  return .init(contentView: cell)
}
