// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "PopupKit",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "PopupKit",  // 对外 `import PopupKit`
            targets: ["PopupKit"]
        ),
    ],
    targets: [
        .target(
            name: "PopupKit",
            dependencies: [],
            path: "Sources/PopupKit",
            resources: [.process("PrivacyInfo.xcprivacy")]
        ),
        .testTarget(
            name: "PopupKitTests",
            dependencies: ["PopupKit"],
            path: "Tests/PopupKitTests"
        )
    ]
)
