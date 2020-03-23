// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "XCTestExtensions",
    products: [
        .library(
            name: "XCTestExtensions",
            targets: ["XCTestExtensions"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "XCTestExtensions",
            dependencies: []),
        .testTarget(
            name: "XCTestExtensionsTests",
            dependencies: ["XCTestExtensions"]),
    ]
)
