import Foundation
import UIKit

extension Fluid {
      
  public static func withLocalEnviroment(
    setup: (inout LocalEnvironmentValues) -> Void,
    perform: () -> Void
  ) {
    
    assert(Thread.isMainThread)
        
    var newEnv = LocalEnvironmentValues()
    
    setup(&newEnv)
    
    newEnv.performAsCurrent(perform)
                
  }
  
  public struct LocalEnvironmentValues {
    
    private static var stack: [LocalEnvironmentValues] = []
    
    public static let empty = Self.init()
    
    public static var current: Self {
      stack.last ?? .empty
    }
        
    private var environmentValues: [AnyKeyPath : Any] = [:]
    
    public init() {}
    
    subscript<K>(key: K.Type) -> K.Value? where K : FluidLocalEnvironmentKey {
      get {
        environmentValues[\K.self] as? K.Value
      }
      set {
        environmentValues[\K.self] = newValue
      }
    }
    
    public func performAsCurrent(_ perform: () -> Void) {
      
      assert(Thread.isMainThread)
      
      Self.stack.append(self)
      defer {
        _ = Self.stack.popLast()
      }
      
      perform()
        
    }
    
  }
}

public protocol FluidLocalEnvironmentKey {
  associatedtype Value
}

extension Fluid {
  /**
   For associating property dynamically as a plugin.
   This idea coming from SwiftUI's EnvironmentValues
   */
  public enum LocalEnvironmentKeys {
    
    public struct FindStrategy: FluidLocalEnvironmentKey {
      public typealias Value = UIViewController.FluidStackFindStrategy
    }
    
    public struct Relation: FluidLocalEnvironmentKey {
      public typealias Value = StackingRelation
    }
    
    public struct AddingTransition: FluidLocalEnvironmentKey {
      public typealias Value = AnyAddingTransition
    }
    
  }
}

extension Fluid.LocalEnvironmentValues {
  
  public var stackFindStrategy: UIViewController.FluidStackFindStrategy? {
    get { self[Fluid.LocalEnvironmentKeys.FindStrategy.self] }
    set { self[Fluid.LocalEnvironmentKeys.FindStrategy.self] = newValue }
  }
  
  public var relation: StackingRelation? {
    get { self[Fluid.LocalEnvironmentKeys.Relation.self] }
    set { self[Fluid.LocalEnvironmentKeys.Relation.self] = newValue }
  }
  
  public var addingTransition: AnyAddingTransition? {
    get { self[Fluid.LocalEnvironmentKeys.AddingTransition.self] }
    set { self[Fluid.LocalEnvironmentKeys.AddingTransition.self] = newValue }
  }

}
