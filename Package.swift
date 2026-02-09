// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LSWaveformKit",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // 主要库产品
        .library(
            name: "LSWaveformKit",
            targets: ["LSWaveformKit"]
        ),
    ],
    dependencies: [
        // 依赖项
        // .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.6.0"),
    ],
    targets: [
        // 核心库目标
        .target(
            name: "LSWaveformKit",
            dependencies: [],
            path: "Sources",
            exclude: [
                "Examples/LSWaveformKitExamples.swift",
                "Resources/PrivacyInfo.xcprivacy"
            ],
            sources: [
                "Core",
                "UIKit",
                "Presets"
            ],
            linkerSettings: [
                .linkedFramework("AVFoundation"),
                .linkedFramework("CoreAudio"),
                .linkedFramework("Accelerate"),
                .linkedFramework("Metal"),
                .linkedFramework("CoreHaptics")
            ]
        )
    ]
)
