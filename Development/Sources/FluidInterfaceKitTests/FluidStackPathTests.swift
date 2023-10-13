import FluidInterfaceKit
import XCTest

@MainActor
final class FluidStackPathTests: XCTestCase {

  func test_identifiable() {

    class A: UIViewController, FluidIdentifiableViewController {
      var fluidIdentifier: String { "1" }
    }

    class B: UIViewController, FluidIdentifiableViewController {
      var fluidIdentifier: String { "1" }
    }

    XCTAssertNotEqual(
      FluidStackPath.Component.Identifiable(A()),
      FluidStackPath.Component.Identifiable(B())
    )

    XCTAssertNotNil(FluidStackPath.Component.Identifiable(A()).restore(A.self))
    XCTAssertNil(FluidStackPath.Component.Identifiable(A()).restore(B.self))

  }
}
