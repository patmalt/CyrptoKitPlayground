// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "aes128",
    platforms: [.macOS("10.15")],
    products: [
        .executable(name: "aes128", targets: ["aes128"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "aes128",
            dependencies: []),
        .testTarget(
            name: "aes128Tests",
            dependencies: ["aes128"])
    ]
)
