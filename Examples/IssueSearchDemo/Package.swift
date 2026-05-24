// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "IssueSearchDemo",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "IssueSearchDemo",
            targets: ["IssueSearchDemo"]
        )
    ],
    dependencies: [
        .package(name: "Actuate", path: "../..")
    ],
    targets: [
        .target(
            name: "IssueSearchDemo",
            dependencies: [
                .product(name: "Actuate", package: "Actuate")
            ],
            path: "Sources/IssueSearchDemo"
        ),
        .testTarget(
            name: "IssueSearchDemoTests",
            dependencies: [
                "IssueSearchDemo",
                .product(name: "Actuate", package: "Actuate"),
            ],
            path: "Tests/IssueSearchDemoTests"
        ),
    ],
    swiftLanguageModes: [.v6]
)
