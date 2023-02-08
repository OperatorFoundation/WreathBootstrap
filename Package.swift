// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Discovery",
    platforms: [
        .macOS(.v13),
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "DiscoveryBootstrap",
            targets: ["DiscoveryBootstrap"]),
        .library(
            name: "DiscoveryClient",
            targets: ["DiscoveryClient"]),
        .executable(
            name: "DiscoveryServer",
            targets: ["DiscoveryServer"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/OperatorFoundation/Arcadia", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/Antiphony", branch: "main"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.1"),
        
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "DiscoveryBootstrap",
            dependencies: [
                "Arcadia",
            ]),
        .target(
            name: "DiscoveryClient",
            dependencies: [
                "Antiphony",
                "DiscoveryBootstrap",
            ]),
        .executableTarget(
            name: "DiscoveryServer",
            dependencies: [
                "Antiphony",
                "DiscoveryBootstrap",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]),
        .testTarget(
            name: "DiscoveryTests",
            dependencies: ["DiscoveryBootstrap", "DiscoveryClient", "DiscoveryServer"]),
    ],
    swiftLanguageVersions: [.v5]
)
