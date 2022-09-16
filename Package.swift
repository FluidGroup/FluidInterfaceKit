// swift-tools-version:5.5
import PackageDescription

let package = Package(
  name: "FluidInterfaceKit",
  platforms: [
    .iOS(.v13)
  ],
  products: [
    .library(name: "FluidInterfaceKit", targets: ["FluidInterfaceKit"]),
    .library(name: "FluidInterfaceKitRideauSupport", targets: ["FluidInterfaceKitRideauSupport"]),
  ],
  dependencies: [
    .package(
      name: "MatchedTransition",
      url: "https://github.com/muukii/MatchedTransition",
      .upToNextMajor(from: "1.1.0")
    ),
    .package(
      name: "GeometryKit",
      url: "https://github.com/muukii/GeometryKit",
      .upToNextMajor(from: "1.1.0")
    ),
    .package(
      name: "ResultBuilderKit",
      url: "https://github.com/muukii/ResultBuilderKit.git",
      .upToNextMajor(from: "1.2.0")
    ),
    .package(
      name: "Rideau",
      url: "https://github.com/muukii/Rideau.git",
      .upToNextMajor(from: "2.1.0")
    ),
    .package(url: "https://github.com/apple/swift-docc-plugin.git", branch: "main"),    
  ],
  targets: [
    .target(
      name: "FluidInterfaceKit",
      dependencies: ["MatchedTransition", "GeometryKit", "ResultBuilderKit"]
    ),
    .target(
      name: "FluidInterfaceKitRideauSupport",
      dependencies: ["FluidInterfaceKit", "Rideau"]
    ),
  ]
)
