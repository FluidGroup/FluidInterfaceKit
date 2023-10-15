
import Foundation
import XCTest

@testable import FluidStack

final class FluidLocalEnvironmentTests: XCTestCase {
  
  @MainActor
  func testBasic() {
    
    XCTAssertEqual(Fluid.Transaction.current.relation, nil)
    
    Fluid.withTransaction {
      $0.relation = .modality
    } perform: {
      
      XCTAssertEqual(Fluid.Transaction.current.relation, .modality)
      
    }

    XCTAssertEqual(Fluid.Transaction.current.relation, nil)
  }
  
}
