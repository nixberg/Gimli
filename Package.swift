// swift-tools-version:5.4

import PackageDescription

let package = Package(
    name: "gimli-swift",
    products: [
        .library(
            name: "Gimli",
            targets: ["Gimli"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
        .package(url: "https://github.com/nixberg/endianbytes-swift", from: "0.2.0"),
    ],
    targets: [
        .target(
            name: "Gimli",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "EndianBytes", package: "endianbytes-swift"),
            ]),
        .testTarget(
            name: "GimliTests",
            dependencies: ["Gimli"]),
    ]
)
