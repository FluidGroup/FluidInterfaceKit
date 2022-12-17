
import Foundation
import XCTest

@testable import FluidInterfaceKit

final class FluidLocalEnvironmentTests: XCTestCase {
  
  func testBasic() {
    
    XCTAssertEqual(Fluid.Transaction.current.relation, nil)
    
    Fluid.withLocalEnviroment {
      $0.relation = .modality
    } perform: {
      
      XCTAssertEqual(Fluid.Transaction.current.relation, .modality)
      
    }

    XCTAssertEqual(Fluid.Transaction.current.relation, nil)
  }
  
}
