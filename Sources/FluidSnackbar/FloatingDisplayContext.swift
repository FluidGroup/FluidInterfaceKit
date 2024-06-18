import SwiftUI
import SwiftUIHosting
import UIKit

/// A context object that provides a concrete view to display
open class FloatingDisplayContext: Hashable {

  public static func == (lhs: FloatingDisplayContext, rhs: FloatingDisplayContext) -> Bool {
    lhs === rhs
  }

  public func hash(into hasher: inout Hasher) {
    ObjectIdentifier(self).hash(into: &hasher)
  }

  private let factory: () -> FloatingDisplayViewType

  public let transition: FloatingDisplayTransitionType

  public let position: FloatingDisplayController.DisplayPosition

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
}

extension FloatingDisplayContext {

  public convenience init<Content: View>(
    position: FloatingDisplayController.DisplayPosition,
    transition: FloatingDisplayTransitionType,
    @ViewBuilder content: @escaping () -> Content
  ) {

    self.init(
      viewBuilder: {
        _HostingWrapperView(hostingView: SwiftUIHostingView(content: content))
      },
      position: position,
      transition: transition
    )

  }

}

private final class _HostingWrapperView: UIView, FloatingDisplayViewType {

  private let hostingView: SwiftUIHostingView

  init(hostingView: SwiftUIHostingView) {
    self.hostingView = hostingView
    super.init(frame: .zero)
    addSubview(hostingView)
    hostingView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      hostingView.topAnchor.constraint(equalTo: topAnchor),
      hostingView.bottomAnchor.constraint(equalTo: bottomAnchor),
      hostingView.leadingAnchor.constraint(equalTo: leadingAnchor),
      hostingView.trailingAnchor.constraint(equalTo: trailingAnchor)
    ])
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func didPrepare(dismissClosure: @escaping (Bool) -> Void) {
  }

  func willAppear() {
  }

  func didAppear() {
  }

  func willDisappear() {
  }

  func didDisappear() {
  }
}
