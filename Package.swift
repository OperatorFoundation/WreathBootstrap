// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WreathBootstrap",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "WreathBootstrapClient",
            targets: ["WreathBootstrapClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/OperatorFoundation/Arcadia", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/Antiphony", branch: "main"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.1"),
        
    ],
    targets: [
        .target(
            name: "WreathBootstrap",
            dependencies: [
                "Arcadia",
            ]),
        .target(
            name: "WreathBootstrapClient",
            dependencies: [
                "Antiphony",
                "WreathBootstrap",
            ]),
        .executableTarget(
            name: "WreathBootstrapServer",
            dependencies: [
                "Antiphony",
                "WreathBootstrap",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]),
        .testTarget(
            name: "WreathBootstrapTests",
            dependencies: ["WreathBootstrap", "WreathBootstrapClient", "WreathBootstrapServer"]),
    ],
    swiftLanguageVersions: [.v5]
)
