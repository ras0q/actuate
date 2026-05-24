// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "Actuate",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "Actuate",
            targets: ["Actuate"]
        )
    ],
    targets: [
        .target(
            name: "ActuateCore"
        ),
        .target(
            name: "ActuateSwiftUI",
            dependencies: [
                "ActuateCore"
            ]
        ),
        .target(
            name: "Actuate",
            dependencies: [
                "ActuateCore",
                "ActuateSwiftUI",
            ]
        ),
        .testTarget(
            name: "ActuateCoreTests",
            dependencies: ["ActuateCore"]
        ),
        .testTarget(
            name: "ActuateSwiftUITests",
            dependencies: ["ActuateSwiftUI"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
