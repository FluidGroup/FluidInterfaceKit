extension AnyRemovingTransition {

  public static var disabled: Self {
    return .init { context in
      context.notifyAnimationCompleted()
    }
  }
  
  @available(*, deprecated, renamed: "disabled")
  public static var noAnimation: Self {
    return disabled
  }
}
