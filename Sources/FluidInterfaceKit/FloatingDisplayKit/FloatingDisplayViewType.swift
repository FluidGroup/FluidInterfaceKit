
import UIKit

// TODO: Rename
public protocol FloatingDisplayViewType where Self : UIView {

  // MARK: - LifeCycle

  /**
   - parameter manualDismissClosure: Call this closure to dismiss the notification view
   */
  func didPrepare(dismissClosure: @escaping (/*animated: */Bool) -> Void)

  func willAppear()
  func didAppear()

  func willDisappear()
  func didDisappear()
}
