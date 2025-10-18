// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Slackito",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "Slackito",
            targets: ["Slackito"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/platacard/cronista.git", from: "1.0.3"),
    ],
    targets: [
        .target(
            name: "Slackito",
            dependencies: [
                .product(name: "Cronista", package: "cronista")
            ]
        ),
        .testTarget(
            name: "SlackitoTests",
            dependencies: ["Slackito"],
            path: "Tests/Slackito"
        ),
    ]
)
