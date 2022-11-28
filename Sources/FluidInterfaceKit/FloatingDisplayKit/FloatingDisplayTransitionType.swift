
import UIKit

@available(*, deprecated, renamed: "FloatingDisplayTransitionType")
public typealias SnackbarAnimatorType = FloatingDisplayTransitionType

public protocol FloatingDisplayTransitionType {

  func applyPresentAnimation(notificationView: FloatingDisplayViewType, completion: @escaping () -> Void)

  func applyDismissAnimation(notificationView: FloatingDisplayViewType, completion: @escaping () -> Void)
}
