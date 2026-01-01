// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ForceScale",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(name: "ForceScaleCore", targets: ["ForceScaleCore"]),
        .executable(name: "forcescale", targets: ["ForceScaleCLI"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0")
    ],
    targets: [
        .target(
            name: "ForceScaleCore",
            dependencies: [],
            path: "Sources/ForceScaleCore"
        ),
        .executableTarget(
            name: "ForceScaleCLI",
            dependencies: [
                "ForceScaleCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Sources/ForceScaleCLI"
        ),
        .testTarget(
            name: "ForceScaleTests",
            dependencies: ["ForceScaleCore"],
            path: "Tests/ForceScaleTests"
        )
    ]
)
