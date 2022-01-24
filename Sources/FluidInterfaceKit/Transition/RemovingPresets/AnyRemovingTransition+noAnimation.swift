extension AnyRemovingTransition {

  public static var noAnimation: Self {
    return .init { context in
      context.notifyAnimationCompleted()
    }
  }
}
