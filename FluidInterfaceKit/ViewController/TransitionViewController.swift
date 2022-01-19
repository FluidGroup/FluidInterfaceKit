import UIKit

/// Supports transition
/// compatible with ``FluidStackController``
open class TransitionViewController: _fluid_WrapperViewController {

  private struct State: Equatable {

    var countViewDidAppear = 0

  }

  private var state: State = .init()

  public var addingTransition: AnyAddingTransition?
  public var removingTransition: AnyRemovingTransition?

  private var addingTransitionContext: AddingTransitionContext?
  private var removingTransitionContext: RemovingTransitionContext?

  public init(
    addingTransition: AnyAddingTransition?,
    removingTransition: AnyRemovingTransition?
  ) {

    self.addingTransition = addingTransition
    self.removingTransition = removingTransition

    super.init()
    setup()
  }

  public init(
    bodyViewController: UIViewController,
    addingTransition: AnyAddingTransition?,
    removingTransition: AnyRemovingTransition?
  ) {

    self.addingTransition = addingTransition
    self.removingTransition = removingTransition
    super.init(bodyViewController: bodyViewController)
    setup()
  }

  public init(
    view: UIView,
    addingTransition: AnyAddingTransition?,
    removingTransition: AnyRemovingTransition?
  ) {

    self.addingTransition = addingTransition
    self.removingTransition = removingTransition
    super.init(view: view)
    setup()
  }

  private func setup() {
    modalPresentationStyle = .overCurrentContext
  }

  /// From ``FluidStackController``
  func startAddingTransition(context: AddingTransitionContext) {

    guard let addingTransition = addingTransition else {
      return
    }

    addingTransition.startTransition(
      context: context
    )

  }

  /// From ``FluidStackController``
  func startRemovingTransition(context: RemovingTransitionContext) {

    guard let removingTransition = removingTransition else {
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

        let addingTransition = addingTransition ?? .noAnimation

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

        self.dismiss(animated: false, completion: { [weak self] in
          self?.state.countViewDidAppear = 0
          self?.view.resetToVisible()
        })

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

        self.dismiss(animated: false, completion: { [weak self] in
          self?.state.countViewDidAppear = 0
          self?.view.resetToVisible()
        })

      })

    removingTransitionContext = context

    let transition = removingTransition ?? .noAnimation

    transition.startTransition(context: context)

  }
  
}
