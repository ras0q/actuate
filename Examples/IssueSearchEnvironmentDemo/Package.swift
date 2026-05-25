// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "IssueSearchEnvironmentDemo",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "IssueSearchEnvironmentDemo",
            targets: ["IssueSearchEnvironmentDemo"]
        )
    ],
    dependencies: [
        .package(name: "Actuate", path: "../..")
    ],
    targets: [
        .target(
            name: "IssueSearchEnvironmentDemo",
            dependencies: [
                .product(name: "Actuate", package: "Actuate")
            ],
            path: "Sources/IssueSearchEnvironmentDemo"
        )
    ],
    swiftLanguageModes: [.v6]
)
