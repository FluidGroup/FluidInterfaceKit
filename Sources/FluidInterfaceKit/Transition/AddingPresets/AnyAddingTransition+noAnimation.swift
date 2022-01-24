
extension AnyAddingTransition {
  public static var noAnimation: Self {
    return .init { context in
      context.toViewController.view.alpha = 1
      context.notifyAnimationCompleted()
    }
  }
}
