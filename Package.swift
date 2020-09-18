// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "YouTubeiOSPlayerHelper",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(
            name: "YouTubeiOSPlayerHelper",
            targets: ["YouTubeiOSPlayerHelper"]
        )
    ],
    targets: [
        .target(
            name: "YouTubeiOSPlayerHelper",
            path: "Sources",
            resources: [
                .process("Assets")
            ],
            publicHeadersPath: "."
        )
    ]
)
