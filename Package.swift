// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CycleTracker",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "CycleTracker",
            targets: ["CycleTracker"]
        )
    ],
    dependencies: [
        // Dependencies here
    ],
    targets: [
        .target(
            name: "CycleTracker",
            dependencies: [],
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "CycleTrackerTests",
            dependencies: ["CycleTracker"]
        )
    ]
)
