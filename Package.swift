// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "gimli-swift",
    products: [
        .library(
            name: "Gimli",
            targets: ["Gimli"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms", from: "0.1.1"),
    ],
    targets: [
        .target(
            name: "Gimli",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
            ]),
        .testTarget(
            name: "GimliTests",
            dependencies: ["Gimli"]),
    ]
)
