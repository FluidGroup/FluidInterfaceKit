import Foundation
import UIKit

private let environmentValuesKey = "Fluid.withEnviroment"

var environmentValues: [AnyKeyPath : Any] {
  get {
    Thread.current.threadDictionary[environmentValuesKey] as? [AnyKeyPath : Any] ?? [:]
  } set {
    Thread.current.threadDictionary[environmentValuesKey] = newValue
  }
}

extension Fluid {
      
  public static func withLocalEnviroment(
    setup: (inout LocalEnvironmentValues) -> Void,
    perform: () -> Void
  ) {
    
    Thread.current.threadDictionary[environmentValuesKey] = nil
    
    setup(&LocalEnvironmentValues.current)
    
    perform()
    
    Thread.current.threadDictionary[environmentValuesKey] = nil
    
  }
  
  public struct LocalEnvironmentValues {
    
    static var current = Self.init()
    
    private init() {}
    
    subscript<K>(key: K.Type) -> K.Value? where K : FluidLocalEnvironmentKey {
      get {
        environmentValues[\K.self] as? K.Value
      }
      nonmutating set {
        environmentValues[\K.self] = newValue
      }
    }
  }
}

public protocol FluidLocalEnvironmentKey {
  associatedtype Value
}

extension Fluid {
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
  
  public var target: UIViewController.FluidStackFindStrategy? {
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
