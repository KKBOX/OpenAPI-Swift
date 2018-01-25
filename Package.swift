// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OpenAPI-Swift",
    products: [
        .library(
            name: "OpenAPI-Swift",
            targets: ["OpenAPI-Swift"]),
    ],
    dependencies: [
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "OpenAPI-Swift",
            dependencies: []),
        .testTarget(
            name: "OpenAPI-SwiftTests",
            dependencies: ["OpenAPI-Swift"]),
    ]
)
