// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "FluidInterfaceKit",
    platforms: [
        .iOS(.v12),
    ],
    products: [
        .library(name: "FluidInterfaceKit", targets: ["FluidInterfaceKit"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "FluidInterfaceKit",
            dependencies: [],
            path: "FluidInterfaceKit"
        )
    ]
)

