
import UIKit

public protocol FloatingDisplayTransitionType {

  func applyPresentAnimation(notificationView: FloatingDisplayViewType, completion: @escaping () -> Void)

  func applyDismissAnimation(notificationView: FloatingDisplayViewType, completion: @escaping () -> Void)
}
