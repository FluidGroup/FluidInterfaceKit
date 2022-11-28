import UIKit

@available(*, deprecated, renamed: "FloatingDisplayController")
public typealias SnackbarController = FloatingDisplayController

open class FloatingDisplayController {

  private struct State: Equatable {

    var displayingInQueue: Set<FloatingDisplayContext> = .init()
    var displaying: Set<FloatingDisplayContext> = .init()

    var hasDisplaying: Bool {
      displayingInQueue.isEmpty == false || displaying.isEmpty == false
    }
  }

  public enum DisplayPosition {
    case top
    case center
    case bottom(paddingBottom: CGFloat)
  }

  // MARK: - Properties

  fileprivate var queue: [FloatingDisplayContext] = []

  public let displayTarget: FloatingDisplayTarget = .init()

  private var state: State = .init() {
    didSet {
      changedState(state)
    }
  }

  // MARK: - Initializers

  public init() {

  }

  // MARK: - Functions

  private func drain() {

    guard queue.isEmpty == false else {
      return
    }

    if state.displayingInQueue.isEmpty {

      let itemToDisplay = queue.removeFirst()
      state.displayingInQueue.insert(itemToDisplay)

      _display(
        context: itemToDisplay,
        onDidDismiss: { _ in
          let result = self.state.displayingInQueue.remove(itemToDisplay)
          assert(result != nil, "Attempted to remove an item that's not included displaying items.")
          self.drain()
        }
      )

    }

  }

  private func changedState(_ state: State) {

    if state.hasDisplaying {
      displayTarget.visibleWindow()
    } else {
      displayTarget.hideWindow()
    }

  }

  private func enqueue(context: FloatingDisplayContext) {
    assert(Thread.isMainThread)
    queue.append(context)
    drain()
  }

  open func display(context: FloatingDisplayContext, waitsInQueue: Bool) {
    assert(Thread.isMainThread)

    if waitsInQueue {
      enqueue(context: context)
    } else {
      state.displaying.insert(context)
      _display(
        context: context,
        onDidDismiss: { _ in
          self.state.displaying.remove(context)
        }
      )
    }

  }

  @available(*, deprecated)
  open func deliver(
    notification context: FloatingDisplayContext,
    animator: FloatingDisplayTransitionType
  ) {
    assert(Thread.isMainThread)

    context.transition = animator
    enqueue(context: context)
  }

  private func _display(
    context: FloatingDisplayContext,
    onDidDismiss: @escaping (FloatingDisplayViewType) -> Void
  ) {

    func removeNotificationViewClosure(
      notificationView: FloatingDisplayViewType,
      transition: FloatingDisplayTransitionType,
      completion: @escaping (FloatingDisplayViewType) -> Void
    ) -> (Bool) -> Void {
      return { [weak notificationView] animated in

        guard let notificationView = notificationView else {
          // Already dismissed.
          return
        }

        guard notificationView.window != nil else {
          // Already dismissed.
          return
        }

        notificationView.willDisappear()

        if animated {
          transition
            .applyDismissAnimation(notificationView: notificationView) { [weak notificationView] in

              guard let notificationView = notificationView else { return }

              notificationView.didDisappear()
              notificationView.removeFromSuperview()
              completion(notificationView)
            }
        } else {
          notificationView.didDisappear()
          notificationView.removeFromSuperview()
          completion(notificationView)
        }
      }
    }

    func layoutTop(view: UIView, targetView: UIView) {
      view.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        view.topAnchor.constraint(equalTo: targetView.safeAreaLayoutGuide.topAnchor),
        view.rightAnchor.constraint(equalTo: targetView.rightAnchor),
        view.leftAnchor.constraint(equalTo: targetView.leftAnchor),
      ])
    }

    func layoutBottom(view: UIView, targetView: UIView, paddingBottom: CGFloat) {
      view.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        view.bottomAnchor.constraint(equalTo: targetView.safeAreaLayoutGuide.bottomAnchor, constant: -paddingBottom),
        view.rightAnchor.constraint(equalTo: targetView.rightAnchor),
        view.leftAnchor.constraint(equalTo: targetView.leftAnchor),
      ])
    }

    func layoutCenter(view: UIView, targetView: UIView) {
      view.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        view.centerYAnchor.constraint(equalTo: targetView.centerYAnchor),
        view.centerXAnchor.constraint(equalTo: targetView.centerXAnchor),
        view.rightAnchor.constraint(lessThanOrEqualTo: targetView.safeAreaLayoutGuide.rightAnchor),
        view.leftAnchor.constraint(greaterThanOrEqualTo: targetView.safeAreaLayoutGuide.leftAnchor),
        view.topAnchor.constraint(greaterThanOrEqualTo: targetView.safeAreaLayoutGuide.topAnchor),
        view.bottomAnchor.constraint(
          lessThanOrEqualTo: targetView.safeAreaLayoutGuide.bottomAnchor
        ),
      ])
    }

    let notificationView = context.makeView()
    context.setView(notificationView)

    let position = context.position
    let transition = context.transition

    let targetView = displayTarget.contentView

    ///
    notificationView.translatesAutoresizingMaskIntoConstraints = false
    targetView.addSubview(notificationView)

    ///

    switch position {
    case .top:
      layoutTop(view: notificationView, targetView: targetView)
    case .center:
      layoutCenter(view: notificationView, targetView: targetView)
    case .bottom(let paddingBottom):
      layoutBottom(view: notificationView, targetView: targetView, paddingBottom: paddingBottom)
    }

    targetView.layoutIfNeeded()

    ///

    validation: do {

      let size = notificationView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
      if size.height == 0 || size.width == 0 {
        assertionFailure("NotificationView will not be appear.")
      }

    }

    notificationView.didPrepare(
      dismissClosure: removeNotificationViewClosure(
        notificationView: notificationView,
        transition: transition,
        completion: onDidDismiss
      )
    )

    notificationView.willAppear()

    transition
      .applyPresentAnimation(notificationView: notificationView) { [weak notificationView] in

        guard let notificationView = notificationView else {
          return
        }

        notificationView.didAppear()
      }
  }

}
