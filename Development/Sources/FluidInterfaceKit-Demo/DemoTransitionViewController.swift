import CompositionKit
import FluidStack
import Foundation
import MondrianLayout
import ResultBuilderKit
import StorybookKit
import UIKit

final class DemoTransitionViewController: FluidStackController {

  private final class RootViewController: FluidViewController {}

  private let rootController = RootViewController()

  init() {
    super.init(configuration: .init(retainsRootViewController: true))
    definesPresentationContext = true
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    rootController.view.backgroundColor = .systemBackground

    addContentViewController(rootController, transition: .disabled)

    let list = VGridView(numberOfColumns: 1)

    Mondrian.buildSubviews(on: rootController.view) {
      ZStackBlock(alignment: .attach(.all)) {
        list
          .viewBlock
      }
      .container(respectingSafeAreaEdges: .all)
    }

    list.setContents(
      buildArray {

        Self.makeCell(
          title: "popup",
          onTap: { [unowned self] in

            _display(transition: .popup(), removingInteraction: nil)
          }
        )

        Self.makeCell(
          title: "fadeIn",
          onTap: { [unowned self] in

            _display(transition: .fadeIn(), removingInteraction: nil)
          }
        )

        Self.makeCell(
          title: "push",
          onTap: { [unowned self] in

            _display(
              transition: .navigationStyle,
              removingInteraction: .leftToRight
            )
          }
        )
        
        Self.makeCell(
          title: "jump",
          onTap: { [unowned self] in
            
            _display(
              transition: .jump,
              removingInteraction: .disabled
            )
          }
        )
      }
    )

  }

  private func _display(transition: AnyAddingTransition, removingInteraction: AnyRemovingInteraction?) {

    let body = PlaceholderViewController(
      dismissNoAnimation: { instance in
        instance.fluidStackContext?.removeSelf(transition: .disabled)
      },
      dismissFadeOut: { instance in
        instance.fluidStackContext?.removeSelf(transition: .fadeOut())
      },
      pop: { instance in
        instance.fluidStackContext?.removeSelf(transition: .navigationStyle)
      }
    )

    let controller = FluidViewController(
      content: .init(bodyViewController: body)    
    )
    
    body.navigationItem.leftBarButtonItem = .fluidChevronBackward { [unowned body] in
      body.fluidPop(transition: .navigationStyle)
    }
    
    addContentViewController(controller, transition: transition)

  }

  private static func makeCell(title: String, onTap: @escaping () -> Void) -> UIView {
    let button = UIButton(type: .system)
    button.setTitle(title, for: .normal)
    button.onTap {
      onTap()
    }

    return AnyUIView { _ in
      VStackBlock {
        button
      }
      .padding(10)
    }
  }

}

private final class PlaceholderViewController: UIViewController {

  private let _dismissNoAnimation: (PlaceholderViewController) -> Void
  private let _dismissFadeOut: (PlaceholderViewController) -> Void
  private let _pop: (PlaceholderViewController) -> Void

  init(
    dismissNoAnimation: @escaping (PlaceholderViewController) -> Void,
    dismissFadeOut: @escaping (PlaceholderViewController) -> Void,
    pop: @escaping (PlaceholderViewController) -> Void
  ) {
    self._dismissNoAnimation = dismissNoAnimation
    self._dismissFadeOut = dismissFadeOut
    self._pop = pop
    super.init(nibName: nil, bundle: nil)
  }

  required init?(
    coder: NSCoder
  ) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .neonRandom()

    let dismissNoAnimationButton = UIButton(type: .system)&>.do {
      $0.setTitle("Dismiss(noAnimation)", for: .normal)
      $0.onTap { [unowned self] in
        _dismissNoAnimation(self)
      }
    }
    let dismissFadeOutButton = UIButton(type: .system)&>.do {
      $0.setTitle("Dismiss(fadeOut)", for: .normal)
      $0.onTap { [unowned self] in
        _dismissFadeOut(self)
      }
    }

    let popButton = UIButton(type: .system)&>.do {
      $0.setTitle("Pop", for: .normal)
      $0.onTap { [unowned self] in
        _pop(self)
      }
    }

    Mondrian.buildSubviews(on: view) {
      ZStackBlock {
        VStackBlock {
          dismissNoAnimationButton
          dismissFadeOutButton
          popButton
        }
      }
    }

  }

}
