// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Bootstrap",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "BootstrapClient",
            targets: ["BootstrapClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/OperatorFoundation/Arcadia", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/Antiphony", branch: "main"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.1"),
        
    ],
    targets: [
        .target(
            name: "Bootstrap",
            dependencies: [
                "Arcadia",
            ]),
        .target(
            name: "BootstrapClient",
            dependencies: [
                "Antiphony",
                "Bootstrap",
            ]),
        .executableTarget(
            name: "BootstrapServer",
            dependencies: [
                "Antiphony",
                "Bootstrap",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]),
        .testTarget(
            name: "BootstrapTests",
            dependencies: ["Bootstrap", "BootstrapClient", "BootstrapServer"]),
    ],
    swiftLanguageVersions: [.v5]
)
