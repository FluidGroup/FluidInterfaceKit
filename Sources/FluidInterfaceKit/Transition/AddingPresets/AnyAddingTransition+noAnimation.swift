
extension AnyAddingTransition {
  public static var disabled: Self {
    return .init { context in
      context.toViewController.view.alpha = 1
      context.notifyAnimationCompleted()
    }
  }
  
  @available(*, deprecated, renamed: "disabled")
  public static var noAnimation: Self {
    return disabled
  }
}
