
import UIKit

/**
 A context object that provides a concrete view to display
 */
open class FloatingDisplayContext: Hashable {

  public static func ==(lhs: FloatingDisplayContext, rhs: FloatingDisplayContext) -> Bool {
    lhs === rhs
  }

  public func hash(into hasher: inout Hasher) {
    ObjectIdentifier(self).hash(into: &hasher)
  }

  private let factory: () -> FloatingDisplayViewType

  public var transition: FloatingDisplayTransitionType

  public var position: FloatingDisplayController.DisplayPosition

  /// A view that currently displaying.
  public private(set) weak var view: FloatingDisplayViewType?

  /// A Boolean value that indicates deliverly was cancelled.
  open var wasCancelled: Bool = false

  @available(*, deprecated, message: "Use the new initializer")
  public init(
    factory: @escaping () -> FloatingDisplayViewType
  ) {
    self.factory = factory
    self.transition = FloatingDisplaySlideInTrantision()
    self.position = .top
  }

  public init(
    viewBuilder: @escaping () -> FloatingDisplayViewType,
    position: FloatingDisplayController.DisplayPosition,
    transition: FloatingDisplayTransitionType
  ) {
    self.factory = viewBuilder
    self.transition = transition
    self.position = position
  }

  func makeView() -> FloatingDisplayViewType {
    factory()
  }

  func setView(_ view: FloatingDisplayViewType) {
    self.view = view
  }
}
