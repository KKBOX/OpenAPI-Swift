// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "KKBOXOpenAPISwift",
    products: [
        .library(
            name: "KKBOXOpenAPISwift",
            targets: ["KKBOXOpenAPISwift"]),
    ],
    dependencies: [
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "KKBOXOpenAPISwift",
            dependencies: []),
        .testTarget(
            name: "KKBOXOpenAPISwiftTests",
            dependencies: ["KKBOXOpenAPISwift"]),
    ]
)
