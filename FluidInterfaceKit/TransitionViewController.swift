import UIKit

/// Supports transition
/// compatible with ``ZStackViewController``
open class TransitionViewController: WrapperViewController {

  private struct State: Equatable {

    var countViewDidAppear = 0

  }

  private var state: State = .init()

  public var transition: TransitionPair

  public init(
    bodyViewController: UIViewController,
    transition: TransitionPair
  ) {

    self.transition = transition
    super.init(bodyViewController: bodyViewController)
    setup()
  }

  public init(
    view: UIView,
    transition: TransitionPair
  ) {

    self.transition = transition
    super.init(view: view)
    setup()
  }

  private func setup() {
    modalPresentationStyle = .overCurrentContext
  }

  /// From ``ZStackViewController``
  func startAddingTransition(context: AddingTransitionContext) {

    guard let addingTransition = transition.adding else {
      return
    }

    addingTransition.startTransition(
      context: context
    )

  }

  /// From ``ZStackViewController``
  func startRemovingTransition(context: RemovingTransitionContext) {

    guard let removingTransition = transition.removing else {
      context.notifyCompleted()
      return
    }

    removingTransition.startTransition(context: context)
  }

  open override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    if state.countViewDidAppear == 0 {
      self.view.alpha = 0
    }

  }

  open override func viewDidAppear(_ animated: Bool) {

    super.viewDidAppear(animated)

    state.countViewDidAppear += 1

    if state.countViewDidAppear == 1 {

      self.view.alpha = 1

      /// check if this view controller was presented by presentation(modal)
      if parent == nil,
         let addingTransition = transition.adding,
         let presentingViewController = presentingViewController,
         let presentationController = presentationController
      {

        /// presenting as presentation
        /// super.viewDidAppear(animated)

        addingTransition.startTransition(
          context: .init(
            contentView: presentationController.containerView!,
            fromViewController: presentingViewController,
            toViewController: self,
            onCompleted: { _ in

            }
          )
        )

      }

    }

  }

  func _startStandaloneRemovingTransition() -> RemovingTransitionContext {

    guard parent == nil,
          let presentingViewController = presentingViewController,
          let presentationController = presentationController
    else {
      preconditionFailure()
    }

    return .init(
      contentView: presentationController.containerView!,
      fromViewController: self,
      toViewController: presentingViewController,
      onCompleted: { [weak self] context in

        guard let self = self else { return }

        self.dismiss(animated: false, completion: nil)

      })

  }

//  open override func viewWillDisappear(_ animated: Bool) {
//    super.viewWillDisappear(animated)
//  }
//
//  open func remove(overrideTransition: AnyZStackViewControllerRemovingTransition? = nil) {
//
//  }

}
