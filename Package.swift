// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "swift-log-filewriter",
    platforms: [
        .macOS("10.15.4"), .iOS("13.4")
    ],
    products: [
        .library(
            name: "Filewriter",
            targets: ["Filewriter"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.2")
    ],
    targets: [
        .target(
            name: "Filewriter",
            dependencies: [.product(name: "Logging", package: "swift-log")]),
        .testTarget(
            name: "FilewriterTests",
            dependencies: ["Filewriter"]),
    ]
)
