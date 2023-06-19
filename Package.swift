// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "BHTTPSwift",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(name: "BinaryHTTP", targets: ["BinaryHTTP"]),
    ],
    targets: [
        .target(
            name: "BinaryHTTP"
        ),
        .testTarget(
            name: "BinaryHTTPTests",
            dependencies: ["BinaryHTTP"]
        )
    ]
)
