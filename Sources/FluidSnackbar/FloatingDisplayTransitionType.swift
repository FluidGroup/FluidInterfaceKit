
import UIKit

public protocol FloatingDisplayTransitionType {

  @MainActor
  func applyPresentAnimation(notificationView: FloatingDisplayViewType, completion: @escaping () -> Void)

  @MainActor
  func applyDismissAnimation(notificationView: FloatingDisplayViewType, completion: @escaping () -> Void)
}
