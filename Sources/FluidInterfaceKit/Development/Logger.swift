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

  static let stack: OSLog = makeOSLogInDebug(flagName: "FLUID_LOG_STACK") { OSLog.init(subsystem: "FluidUIKit", category: "Stack") }

  static let pip: OSLog = makeOSLogInDebug(flagName: "FLUID_LOG_PIP") { OSLog.init(subsystem: "FluidUIKit", category: "PIP") }
  
  static let portal: OSLog = makeOSLogInDebug(flagName: "FLUID_LOG_PORTAL") { OSLog.init(subsystem: "FluidUIKit", category: "Portal") }
}
