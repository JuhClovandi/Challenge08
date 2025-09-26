// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PacoteSoundAnalysis",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PacoteSoundAnalysis",
            targets: ["PacoteSoundAnalysis"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PacoteSoundAnalysis"),
        .testTarget(
            name: "PacoteSoundAnalysisTests",
            dependencies: ["PacoteSoundAnalysis"]
        ),
    ]
)
