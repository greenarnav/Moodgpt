// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "MoodGPTDependencies",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "MoodGPTDependencies",
            targets: ["MoodGPTDependenciesTarget"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/google/GoogleSignIn-iOS.git",
            from: "7.0.0"
        ),
    ],
    targets: [
        .target(
            name: "MoodGPTDependenciesTarget",
            dependencies: [
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
                .product(name: "GoogleSignInSwift", package: "GoogleSignIn-iOS")
            ],
            path: "Sources"
        ),
    ]
)
