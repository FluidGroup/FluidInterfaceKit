import UIKit

/// It runs standalone, without using delegate.
/// Passing any actions distinguished each interaction
public final class StandaloneContextMenuInteraction: UIContextMenuInteraction {

  private let proxy: _InteractionDelegateProxy

  public init(
    makeConfiguration: @escaping (CGPoint) -> UIContextMenuConfiguration,
    willPerformPreviewAction: @escaping @MainActor (
      UIContextMenuConfiguration, any UIContextMenuInteractionCommitAnimating
    ) -> Void
  ) {

    let proxy = _InteractionDelegateProxy(
      makeConfiguration: makeConfiguration,
      willPerformPreviewAction: willPerformPreviewAction
    )
    self.proxy = proxy
    super.init(delegate: proxy)
  }

  /**
   Convenience inititalizer for FluidStackController
   */
  public init(
    entryViewController: UIViewController,
    targetStackController: UIViewController.FluidStackFindStrategy,
    destinationViewController: @escaping @MainActor () -> FluidViewController
  ) {

    let proxy = _InteractionDelegateProxy(
      makeConfiguration: {
        location in
        UIContextMenuConfiguration(
          identifier: nil,
          previewProvider: {
            let destination = destinationViewController()
            return destination
          },
          actionProvider: { _ in
            return UIMenu(title: "", children: [])
          }
        )
      },
      willPerformPreviewAction: {
        [weak entryViewController]
        configuration,
        animator in

        animator.addCompletion {

          entryViewController?.fluidPush(
            animator.previewViewController as! FluidViewController,
            target: targetStackController,
            relation: .modality,
            transition: nil,
            completion: nil
          )
        }

      }
    )
    self.proxy = proxy
    super.init(delegate: proxy)

  }

}

private final class _InteractionDelegateProxy: NSObject, UIContextMenuInteractionDelegate {

  private let makeConfiguration: @MainActor (CGPoint) -> UIContextMenuConfiguration
  private let willPerformPreviewAction:
    @MainActor (UIContextMenuConfiguration, any UIContextMenuInteractionCommitAnimating) -> Void

  init(
    makeConfiguration: @escaping @MainActor (CGPoint) -> UIContextMenuConfiguration,
    willPerformPreviewAction: @escaping @MainActor (
      UIContextMenuConfiguration, any UIContextMenuInteractionCommitAnimating
    ) -> Void
  ) {
    self.makeConfiguration = makeConfiguration
    self.willPerformPreviewAction = willPerformPreviewAction
  }

  func contextMenuInteraction(
    _ interaction: UIContextMenuInteraction,
    configurationForMenuAtLocation location: CGPoint
  ) -> UIContextMenuConfiguration? {

    makeConfiguration(location)
  }

  func contextMenuInteraction(
    _ interaction: UIContextMenuInteraction,
    willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
    animator: any UIContextMenuInteractionCommitAnimating
  ) {
    willPerformPreviewAction(configuration, animator)
  }

}
