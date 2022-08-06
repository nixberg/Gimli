// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "gimli-swift",
    products: [
        .library(
            name: "Gimli",
            targets: ["Gimli"]),
    ],
    dependencies: [
        .package(url: "https://github.com/nixberg/endianbytes-swift", .upToNextMinor(from: "0.5.0")),
    ],
    targets: [
        .target(
            name: "Gimli",
            dependencies: [
                .product(name: "SIMDEndianBytes", package: "endianbytes-swift"),
            ]),
        .testTarget(
            name: "GimliTests",
            dependencies: ["Gimli"]),
    ]
)
