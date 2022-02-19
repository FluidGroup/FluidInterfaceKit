import Foundation
import os.log

enum Log {

  static func debug(_ log: OSLog, _ object: Any...) {
    os_log(.debug, log: log, "%@", object.map { "\($0)" }.joined(separator: " "))
  }
  
  static func error(_ log: OSLog, _ object: Any...) {
    os_log(.error, log: log, "%@", object.map { "\($0)" }.joined(separator: " "))
  }
  
  static func fault(_ log: OSLog, _ object: Any...) {
    os_log(.fault, log: log, "%@", object.map { "\($0)" }.joined(separator: " "))
  }

}

extension OSLog {

  @inline(__always)
  private static func makeOSLogInDebug(
    flagName: StaticString,
    factory: () -> OSLog
  ) -> OSLog {
#if DEBUG
    guard ProcessInfo.init().environment.contains(where: { $0.key == flagName.description }) else {
      return .disabled
    }
    return factory()
#else
    return .disabled
#endif
  }

  static let stack: OSLog = makeOSLogInDebug(flagName: Fluid.LogCategory.stack.rawValue) { OSLog.init(subsystem: "FluidUIKit", category: "Stack") }

  static let pip: OSLog = makeOSLogInDebug(flagName: Fluid.LogCategory.pip.rawValue) { OSLog.init(subsystem: "FluidUIKit", category: "PIP") }
  
  static let portal: OSLog = makeOSLogInDebug(flagName: Fluid.LogCategory.portal.rawValue) { OSLog.init(subsystem: "FluidUIKit", category: "Portal") }
  
  static let fluidController: OSLog = makeOSLogInDebug(flagName: Fluid.LogCategory.fluidController.rawValue) { OSLog.init(subsystem: "FluidUIKit", category: "FluidController") }
    
  static let viewController: OSLog = makeOSLogInDebug(flagName: Fluid.LogCategory.viewController.rawValue) { OSLog.init(subsystem: "FluidUIKit", category: "ViewController") }
}

extension Fluid {
  
  /**
   To enable logging,
   Set the raw value in name for Xcode scheme environment variable with value to set nil.
   */
  public enum LogCategory: String {
    
    case stack = "FLUID_LOG_STACK"
    case pip = "FLUID_LOG_PIP"
    case portal = "FLUID_LOG_PORTAL"
    case fluidController = "FLUID_LOG_FLUIDCONTROLLER"
    case viewController = "FLUID_LOG_VIEWCONTROLLER"
    
  }
  
}
