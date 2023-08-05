// swift-tools-version:5.5
import PackageDescription

let package = Package(
  name: "FluidInterfaceKit",
  platforms: [
    .iOS(.v13)
  ],
  products: [
    .library(name: "FluidPortal", targets: ["FluidPortal"]),
    .library(name: "FluidInterfaceKit", targets: ["FluidInterfaceKit"]),
    .library(name: "FluidPopover", targets: ["FluidPopover"]),
    .library(name: "FluidInterfaceKitRideauSupport", targets: ["FluidInterfaceKitRideauSupport"]),
  ],
  dependencies: [
    .package(
      name: "GeometryKit",
      url: "https://github.com/FluidGroup/GeometryKit",
      .upToNextMajor(from: "1.1.0")
    ),
    .package(
      name: "ResultBuilderKit",
      url: "https://github.com/FluidGroup/ResultBuilderKit.git",
      .upToNextMajor(from: "1.2.0")
    ),
    .package(
      name: "Rideau",
      url: "https://github.com/FluidGroup/Rideau.git",
      .upToNextMajor(from: "2.1.0")
    ),
    .package(url: "https://github.com/apple/swift-docc-plugin.git", branch: "main"),    
  ],
  targets: [
    .target(
      name: "FluidPortal",
      dependencies: ["FluidRuntime"]
    ),
    .target(
      name: "FluidRuntime"
    ),
    .target(
      name: "FluidPopover",
      dependencies: ["FluidPortal"]
    ),
    .target(
      name: "FluidInterfaceKit",
      dependencies: ["GeometryKit", "ResultBuilderKit", "FluidPortal"]
    ),
    .target(
      name: "FluidInterfaceKitRideauSupport",
      dependencies: ["FluidInterfaceKit", "Rideau"]
    ),
  ]
)
