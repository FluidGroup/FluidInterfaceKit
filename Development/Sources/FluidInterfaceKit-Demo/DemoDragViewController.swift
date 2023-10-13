import FluidGesture
import MondrianLayout

final class DemoDragViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    let draggableView = UIView()
    draggableView.backgroundColor = .blue

    Mondrian.buildSubviews(on: self.view) {
      ZStackBlock {
        draggableView
          .viewBlock
          .size(width: 100, height: 100)
      }
    }

    draggableView.makeDraggable(
      descriptor: .init(
        horizontal: .init(min: -200, max: 200, bandLength: 30),
        vertical: .init(min: -200, max: 200, bandLength: 30),
        handler: .init(onEndDragging: { _, _, _ in .init(width: 30, height: 0) })
      )
    )
  }
}
