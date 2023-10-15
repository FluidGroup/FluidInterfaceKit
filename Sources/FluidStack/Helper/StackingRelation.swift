
public protocol StackingRelationID {
  
}

/**
 A representation of stacking semantics in ``FluidStackController``.
 
 You may create your own semantics.
 
 ```swift
 extension StackingRelation {
   
   public struct YourSemanticsID: RelationID {}
   
   public static var yourSemantics: Self {
     .init(YourSemanticsID.self)
   }
   
 ```
 */
public struct StackingRelation: Equatable {
  
  public static func == (lhs: StackingRelation, rhs: StackingRelation) -> Bool {
    lhs.id == rhs.id
  }
  
  private let id: StackingRelationID.Type
  
  public init(_ id: StackingRelationID.Type) {
    self.id = id
  }
    
}

extension StackingRelation {
  
  public struct HierarchicalNavigationID: StackingRelationID {}
  
  /**
   Transition in the same context, changing the perspective.
   https://developer.apple.com/design/human-interface-guidelines/ios/app-architecture/navigation/
   */
  public static var hierarchicalNavigation: Self {
    .init(HierarchicalNavigationID.self)
  }
  
}

extension StackingRelation {
  
  public struct ModalID: StackingRelationID {}
  
  /**
   Transition to a detached context.
   https://developer.apple.com/design/human-interface-guidelines/ios/app-architecture/modality/
   */
  public static var modality: Self {
    .init(ModalID.self)
  }
  
}
