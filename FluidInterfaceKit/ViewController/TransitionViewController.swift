import UIKit

/// Supports transition
/// compatible with ``ZStackViewController``
open class TransitionViewController: _fluid_WrapperViewController {

  private struct State: Equatable {

    var countViewDidAppear = 0

  }

  private var state: State = .init()

  public var transition: TransitionPair
  private var addingTransitionContext: AddingTransitionContext?
  private var removingTransitionContext: RemovingTransitionContext?

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

    /**
     For standalone usage
     */
    if state.countViewDidAppear == 1 {

      self.view.alpha = 1

      /// check if this view controller was presented by presentation(modal)
      if parent == nil,
         let presentingViewController = presentingViewController,
         let presentationController = presentationController
      {

        removingTransitionContext?.invalidate()
        removingTransitionContext = nil

        let addingTransition = transition.adding ?? .noAnimation

        /// presenting as presentation
        /// super.viewDidAppear(animated)


        let context = AddingTransitionContext.init(
          contentView: presentationController.containerView!,
          fromViewController: presentingViewController,
          toViewController: self,
          onCompleted: { context in

            self.addingTransitionContext = nil

            guard context.isInvalidated == false else {
              return
            }

            context.transitionFinished()
          }
        )

        self.addingTransitionContext = context

        addingTransition.startTransition(
          context: context
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

    addingTransitionContext?.invalidate()
    addingTransitionContext = nil

    let context = RemovingTransitionContext.init(
      contentView: presentationController.containerView!,
      fromViewController: self,
      toViewController: presentingViewController,
      onCompleted: { [weak self] context in

        guard let self = self else { return }

        guard context.isInvalidated == false else { return }

        context.transitionFinished()
        self.removingTransitionContext = nil

        self.dismiss(animated: false, completion: nil)

      })

    removingTransitionContext = context

    return context

  }

  public func remove() {

    guard parent == nil,
          let presentingViewController = presentingViewController,
          let presentationController = presentationController
    else {
      assertionFailure("\(self) is not presented by presentation")
      return
    }

    addingTransitionContext?.invalidate()
    addingTransitionContext = nil

    let context = RemovingTransitionContext.init(
      contentView: presentationController.containerView!,
      fromViewController: self,
      toViewController: presentingViewController,
      onCompleted: { [weak self] context in

        guard let self = self else { return }

        guard context.isInvalidated == false else { return }

        context.transitionFinished()
        self.removingTransitionContext = nil

        self.dismiss(animated: false, completion: nil)

      })

    removingTransitionContext = context

    let transition = transition.removing ?? .noAnimation

    transition.startTransition(context: context)

  }
  
}
