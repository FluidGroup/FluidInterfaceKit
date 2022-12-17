import Foundation
import UIKit

extension Fluid {
      
  @MainActor
  @discardableResult
  public static func withTransaction<R>(
    setup: (inout Transaction) -> Void,
    perform: () -> R
  ) -> R {
    
    assert(Thread.isMainThread)
        
    var newEnv = Transaction()
    
    setup(&newEnv)
    
    return newEnv.performAsCurrent(perform)
                
  }
  
  @MainActor
  public struct Transaction {
    
    private static var stack: [Transaction] = []
    
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
    
    @discardableResult
    public func performAsCurrent<R>(_ perform: () -> R) -> R {
      
      assert(Thread.isMainThread)
      
      Self.stack.append(self)
      defer {
        _ = Self.stack.popLast()
      }
      
      return perform()
        
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
    
    public struct RemovingTransition: FluidLocalEnvironmentKey {
      public typealias Value = AnyRemovingTransition
    }
    
    public struct RemovingInteraction: FluidLocalEnvironmentKey {
      public typealias Value = AnyRemovingInteraction
    }
  }
}

extension Fluid.Transaction {
  
  @MainActor
  public var stackFindStrategy: UIViewController.FluidStackFindStrategy? {
    get { self[Fluid.LocalEnvironmentKeys.FindStrategy.self] }
    set { self[Fluid.LocalEnvironmentKeys.FindStrategy.self] = newValue }
  }
  
  @MainActor
  public var relation: StackingRelation? {
    get { self[Fluid.LocalEnvironmentKeys.Relation.self] }
    set { self[Fluid.LocalEnvironmentKeys.Relation.self] = newValue }
  }
  
  @MainActor
  public var addingTransition: AnyAddingTransition? {
    get { self[Fluid.LocalEnvironmentKeys.AddingTransition.self] }
    set { self[Fluid.LocalEnvironmentKeys.AddingTransition.self] = newValue }
  }

  @MainActor
  public var removingTransition: AnyRemovingTransition? {
    get { self[Fluid.LocalEnvironmentKeys.RemovingTransition.self] }
    set { self[Fluid.LocalEnvironmentKeys.RemovingTransition.self] = newValue }
  }
  
  @MainActor
  public var removingInteraction: AnyRemovingInteraction? {
    get { self[Fluid.LocalEnvironmentKeys.RemovingInteraction.self] }
    set { self[Fluid.LocalEnvironmentKeys.RemovingInteraction.self] = newValue }
  }
}
