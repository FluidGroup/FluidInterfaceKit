import UIKit

public struct FluidStackPath: Equatable {

  public enum Component: Equatable {

    public struct Volatile: Equatable {
      public let objectIdentifier: ObjectIdentifier
      public private(set) weak var ref: UIViewController?
    }

    public struct Identifiable: Equatable {
      public static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs.id == rhs.id else { return false }
        guard lhs.viewControllerType == rhs.viewControllerType else { return false }
        return true
      }
      
      public let id: AnyHashable
      public let viewControllerType: UIViewController.Type

      @MainActor
      public init(_ viewController: some FluidIdentifiableViewController) {
        self.id = viewController.fluidIdentifier as AnyHashable
        self.viewControllerType = type(of: viewController)
      }

      public func restore<Target: FluidIdentifiableViewController>(_ target: Target.Type) -> Target.FluidID? {
        guard viewControllerType == target else { return nil }
        guard let id = id as? Target.FluidID else { return nil }
        return id
      }
    }

    case volatile(Volatile)
    case identifiable(AnyFluidIdentifiableViewController)
  }

  public private(set) var components: [Component] = []

  public init() {

  }

  public init(components: [Component]) {
    self.components = components
  }

  public mutating func append(_ component: Component) {
    components.append(component)
  }

  public mutating func removeLast(_ k: Int = 1) {
    components.removeLast(k)
  }
}

public struct AnyFluidIdentifiableViewController: Equatable {

  public var base: AnyHashable

  public init(_ base: some FluidIdentifiableViewController) {
    self.base = base as AnyHashable
  }

}

@MainActor
public protocol FluidIdentifiableViewController: UIViewController {

  associatedtype FluidID: Hashable

  var fluidIdentifier: FluidID { get }

}
