public struct TransitionPair {

  public var adding: AnyAddingTransition?
  public var removing: AnyRemovingTransition?

  public init(
    adding: AnyAddingTransition?,
    removing: AnyRemovingTransition?
  ) {
    self.adding = adding
    self.removing = removing
  }

  public static var noTransition: Self {
    return .init(adding: nil, removing: nil)
  }
}
