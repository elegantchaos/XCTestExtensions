// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "XCTestExtensions",
    platforms: [
        .macOS(.v10_13), .iOS(.v10), .tvOS(.v10), .watchOS(.v6)
    ],
    products: [
        .library(
            name: "XCTestExtensions",
            targets: ["XCTestExtensions"]),
    ],
    dependencies: [
        .package(url: "https://github.com/elegantchaos/Matchable.git", from: "1.0.6")
    ],
    targets: [
        .target(
            name: "XCTestExtensions",
            dependencies: [
                .product(name: "Matchable", package: "Matchable")
            ]),
        
        .testTarget(
            name: "XCTestExtensionsTests",
            dependencies: ["XCTestExtensions"]),
    ]
)
