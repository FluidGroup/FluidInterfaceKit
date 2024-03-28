import FluidGesture
import MondrianLayout

final class DemoDragViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    let draggableView = UIView()
    draggableView.backgroundColor = .systemBlue

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
        handler: .init(
          onStartDragging: {

          },
          onEndDragging: { velocity, offset, contentSize in
            // return proposed offset to finish dragging
            return .init(width: 0, height: 0)
          }
        )
      )
    )
  }
}

@available(iOS 17, *)
#Preview(traits: .defaultLayout, body: {
  DemoDragViewController()
})
