// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "XCTestExtensions",
    platforms: [
        .macOS(.v10_13)
    ],
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
