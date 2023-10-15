
public struct FluidSourceCodeLocation {
  
  public let file: StaticString
  public let line: UInt
  
  public init(file: StaticString, line: UInt) {
    self.file = file
    self.line = line
  }
  
}
