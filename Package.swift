// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "gimli-swift",
    products: [
        .library(
            name: "Gimli",
            targets: ["Gimli"]),
    ],
    targets: [
        .target(
            name: "Gimli"),
        .testTarget(
            name: "GimliTests",
            dependencies: ["Gimli"]),
    ]
)
