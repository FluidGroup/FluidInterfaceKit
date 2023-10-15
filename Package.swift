// swift-tools-version:5.5
import PackageDescription

let package = Package(
  name: "FluidInterfaceKit",
  platforms: [
    .iOS(.v13)
  ],
  products: [
    .library(name: "FluidPortal", targets: ["FluidPortal"]),
    .library(name: "FluidGesture", targets: ["FluidGesture"]),
    .library(name: "FluidStack", targets: ["FluidStack"]),
    .library(name: "FluidSnackbar", targets: ["FluidSnackbar"]),
    .library(name: "FluidPictureInPicture", targets: ["FluidPictureInPicture"]),
    .library(name: "FluidTooltipSupport", targets: ["FluidTooltipSupport"]),
    .library(name: "FluidStackRideauSupport", targets: ["FluidStackRideauSupport"]),
    .library(name: "FluidKeyboardSupport", targets: ["FluidKeyboardSupport"]),
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
      name: "FluidCore"
    ),
    .target(
      name: "FluidPortal",
      dependencies: ["FluidRuntime"]
    ),
    .target(
      name: "FluidRuntime"
    ),
    .target(name: "FluidGesture"),
    .target(
      name: "FluidTooltipSupport",
      dependencies: ["FluidPortal"]
    ),
    .target(
      name: "FluidStack",
      dependencies: ["GeometryKit", "ResultBuilderKit", "FluidPortal", "FluidCore"]
    ),
    .target(
      name: "FluidSnackbar",
      dependencies: ["FluidCore"]
    ),
    .target(
      name: "FluidPictureInPicture",
      dependencies: ["FluidCore", "FluidStack", "GeometryKit"]
    ),
    .target(
      name: "FluidStackRideauSupport",
      dependencies: ["FluidStack", "Rideau"]
    ),
    .target(name: "FluidKeyboardSupport"),

    .testTarget(name: "FluidStackTests", dependencies: ["FluidStack"])
  ]
)
