
extension AnyAddingTransition {
  public static var noAnimation: Self {
    return .init { context in
      context.notifyCompleted()
    }
  }
}
