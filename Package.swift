// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PacoteSoundAnalysis",
    
    platforms: [
        .iOS(.v15) // Define que seu pacote suporta iOS 15 para cima
    ],
    
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PacoteSoundAnalysis",
            targets: ["PacoteSoundAnalysis"]),
    ],
    dependencies: [],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PacoteSoundAnalysis",
            dependencies: [],
            //linkar os frameworks da aple
            linkerSettings: [
                .linkedFramework("AVFoundation"),
                .linkedFramework("SoundAnalysis"),
            ]
            
        ),
        .testTarget(
            name: "PacoteSoundAnalysisTests",
            dependencies: ["PacoteSoundAnalysis"]
        ),
    ]
)
