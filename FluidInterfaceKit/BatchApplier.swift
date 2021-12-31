
public struct BatchApplier<T> {

  private let targets: [T]

  public init<C: Collection>(_ targets: C) where C.Element == T {
    self.targets = Array(targets)
  }

  public func apply(_ applier: (T) -> Void) {
    targets.forEach { applier($0) }
  }
}

#if canImport(UIKit)
import UIKit

extension BatchApplier where T : UIView {

  /// Controls alpha value with touch handlings living.
  public func setInvisible(_ value: Bool) {
    if value {
      apply { $0.layer.opacity = 0.010001 }
    } else {
      apply { $0.layer.opacity = 1 }
    }
  }
}

#endif
