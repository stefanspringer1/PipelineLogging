// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PipelineLogging",
    platforms: [
        .iOS(.v16),
        .macOS(.v15),
        .tvOS(.v16),
        .watchOS(.v9),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PipelineLogging",
            targets: ["PipelineLogging"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/stefanspringer1/Pipeline.git", from: "1.0.29"),
        .package(url: "https://github.com/stefanspringer1/Logging.git", from: "0.0.8"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PipelineLogging",
            dependencies: [
                "Pipeline",
                "Logging",
            ]
        ),
        .testTarget(
            name: "PipelineLoggingTests",
            dependencies: ["PipelineLogging"]
        ),
    ]
)
