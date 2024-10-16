
import UIKit
import RubberBanding

open class SnackbarDraggableBase : UIView, FloatingDisplayViewType {

  @MainActor
  private struct RubberbandTranslationModel {

    var transform: CGAffineTransform

    init(view: UIView) {
      self.transform = view.transform
    }

    func apply(view: UIView) {
      var t = transform
      if t.ty > 0 {
        t.ty = rubberBand(value: t.ty, min: 0, max: 0, bandLength: 50)
      }
      view.transform = t
    }
  }

  // MARK: - Properties

  public let contentView = UIView()

  private var dismissClosure: ((Bool) -> Void)?
  private var dragging: Bool = false

  open var onTap: (() -> Void)?

  private let topMargin: CGFloat

  private var currentTranslation: RubberbandTranslationModel?

  // MARK: - Initializers

  public init(topMargin: CGFloat) {
    self.topMargin = topMargin
    super.init(frame: .zero)
    setupView()
    setupGesture()
  }

  @available(*, unavailable)
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

    let view = super.hitTest(point, with: event)

    if view == self {

      return nil
    }
    return view
  }

  open func dismiss(animated: Bool) {
    dismissClosure?(animated)
    dismissClosure = nil
  }

  open func didPrepare(dismissClosure: @escaping (Bool) -> Void) {

    self.dismissClosure = dismissClosure
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.5) {
      guard self.dragging == false else {
        return
      }
      dismissClosure(true)
      self.dismissClosure = nil
    }
  }

  open func willAppear() {

  }

  open func didAppear() {

  }

  open func willDisappear() {

  }

  open func didDisappear() {

  }

  open func setupView() {

    backgroundColor = .clear

    contentView.layer.masksToBounds = false

    addSubview(contentView)

    contentView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      contentView.topAnchor.constraint(equalTo: topAnchor, constant: 4 + topMargin),
      contentView.leftAnchor.constraint(equalTo: leftAnchor, constant: 12),
      contentView.rightAnchor.constraint(equalTo: rightAnchor, constant: -12),
      contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 4),
    ])

  }

  private func setupGesture() {

    let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(SnackbarDraggableBase.handleDragGesture(gesture :)))
    contentView.addGestureRecognizer(dragGesture)

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SnackbarDraggableBase.handleTapGesture(gesture:)))
    contentView.addGestureRecognizer(tapGesture)
  }

  @objc
  private dynamic func handleTapGesture(gesture: UITapGestureRecognizer) {

    if case .ended = gesture.state {
      onTap?()
      onTap = nil
      dismiss(animated: true)
    }
  }

  @objc
  private dynamic func handleDragGesture(gesture: UIPanGestureRecognizer) {

    switch gesture.state {
    case .began:

      currentTranslation = .init(view: self)

      dragging = true
    case .ended, .cancelled, .failed:

      dragging = false

      let velocity = gesture.velocity(in: self)

      var shouldDismiss: Bool = false

      if velocity.y < -100 {
        shouldDismiss = true
      }

      if self.layer.frame.minY < -20 {
        shouldDismiss = true
      }

      if shouldDismiss {

        let currentTY = self.transform.ty
        let targetTY = -(self.layer.frame.maxY + self.layer.frame.height)

        let remainingDistance = abs(targetTY - currentTY)
        let v = CGVector(dx: 0, dy: velocity.y / remainingDistance)

        let animator = UIViewPropertyAnimator(
          duration: 0.4,
          timingParameters: UISpringTimingParameters(
            dampingRatio: 1,
            initialVelocity: v
          )
        )

        animator.addAnimations {
          self.transform = CGAffineTransform(translationX: 0, y: targetTY)
        }

        animator.addCompletion { _ in
          self.dismiss(animated: false)
        }

        animator.startAnimation()

      } else {

        let animator = UIViewPropertyAnimator(
          duration: 0.4,
          timingParameters: UISpringTimingParameters(
            dampingRatio: 1,
            initialVelocity: .zero
          )
        )

        animator.addAnimations {
          self.transform = .identity
        }

        animator.addCompletion { _ in
          DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
            guard self.dragging == false else {
              return
            }
            self.dismiss(animated: true)
          }
        }

        animator.startAnimation()

      }
    default:

      let inView = gesture.translation(in: self)

      currentTranslation!.transform = currentTranslation!.transform.translatedBy(x: 0, y: inView.y)
      currentTranslation!.apply(view: self)

    }

    gesture.setTranslation(CGPoint.zero, in: self)
  }

}

