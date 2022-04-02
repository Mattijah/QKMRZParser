// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QKMRZParser",
    products: [
        .library(name: "QKMRZParser", targets: ["QKMRZParser"]),
    ],
    targets: [
        .target(
            name: "QKMRZParser",
            path: "QKMRZParser",
            exclude: ["Info.plist"]
        )
    ]
)
