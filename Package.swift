// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "DawnTransition",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "DawnTransition", 
            targets: ["DawnTransition"]
        ),
    ],
    targets: [
        .target(
            name: "DawnTransition",
            dependencies: [],
            path: "Sources/DawnTransition",
            resources: [.process("PrivacyInfo.xcprivacy")]
        )
    ]
)
