
import Foundation
import XCTest

@testable import FluidInterfaceKit

final class FluidLocalEnvironmentTests: XCTestCase {
  
  func testBasic() {
    
    XCTAssertEqual(Fluid.LocalEnvironmentValues.current.relation, nil)
    
    Fluid.withLocalEnviroment {
      $0.relation = .modality
    } perform: {
      
      XCTAssertEqual(Fluid.LocalEnvironmentValues.current.relation, .modality)
      
    }

    XCTAssertEqual(Fluid.LocalEnvironmentValues.current.relation, nil)
  }
  
}
