import CompositionKit
import FluidInterfaceKit
import Foundation
import MondrianLayout
import StorybookKit
import UIKit

final class DemoTransitionViewController: FluidStackController {

  private let usesFluid: Bool

  init(
    usesFluid: Bool
  ) {
    self.usesFluid = usesFluid
    super.init()
    definesPresentationContext = true
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white

    let list = VGridView(numberOfColumns: 1)

    Mondrian.buildSubviews(on: view) {
      ZStackBlock(alignment: .attach(.all)) {
        list
          .viewBlock
      }
    }

    list.setContents([
      Self.makeCell(
        title: "fade",
        onTap: { [unowned self] in

          _display(transition: .popup())
        }
      )
    ])

  }

  private func _display(transition: AnyAddingTransition) {

    let body = PlaceholderViewController { [usesFluid] instance in
      if usesFluid {
        instance.fluidStackControllerContext?.removeSelf(transition: nil)
      } else {
        instance.dismiss(animated: false, completion: nil)
      }
    }

    if usesFluid {

      let controller = FluidViewController(
        bodyViewController: body,
        transition: .noTransition,
        interactionToRemove: nil
      )

      addContentViewController(controller, transition: transition)

    } else {

      let controller = FluidViewController(
        bodyViewController: body,
        transition: .init(adding: transition, removing: nil),
        interactionToRemove: nil
      )

      present(controller, animated: false, completion: nil)

    }

  }

  private static func makeCell(title: String, onTap: @escaping () -> Void) -> UIView {
    let button = UIButton(type: .system)
    button.setTitle(title, for: .normal)
    button.onTap {
      onTap()
    }

    return AnyView { _ in
      VStackBlock {
        button
      }
      .padding(10)
    }
  }

}

private final class PlaceholderViewController: UIViewController, ViewControllerFluidContentType {

  private let _dismiss: (PlaceholderViewController) -> Void

  init(
    dismiss: @escaping (PlaceholderViewController) -> Void
  ) {
    self._dismiss = dismiss
    super.init(nibName: nil, bundle: nil)
  }

  required init?(
    coder: NSCoder
  ) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = BookGenerator.randomColor()

    let dismissButton = UIButton(type: .system)&>.do {
      $0.setTitle("Dismiss", for: .normal)
      $0.onTap { [unowned self] in
        _dismiss(self)
      }
    }

    Mondrian.buildSubviews(on: view) {
      ZStackBlock {
        VStackBlock {
          dismissButton
        }
      }
    }

  }

}
