// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "swift-ble-macro",
    platforms: [
        .iOS(.v12),
        .macOS(.v14),
        .watchOS(.v4),
        .visionOS(.v1),
        .tvOS(.v12),
    ],
    products: [
        .library(
            name: "BLEMacro",
            targets: ["BLEMacro"]
        ),
        .library(
            name: "BLEMacroEasy",
            targets: ["BLEMacroEasy"]
        ),
        .library(
            name: "BLECommand",
            targets: ["BLEMacroCompiler"]
        ),
        .library(
            name: "BLEMacroCompiler",
            targets: ["BLEMacroCompiler"]
        ),
        .library(
            name: "BLEInternal",
            targets: ["BLEInternal"]
        ),
        .library(
            name: "BLEInterpreter",
            targets: ["BLEInterpreter"]
        ),
        .library(
            name: "CoreBluetoothTestable",
            targets: ["CoreBluetoothTestable"]
        ),
        .library(
            name: "BLEAssignedNumbers",
            targets: ["BLEAssignedNumbers"]
        ),
        .library(
            name: "BLEModel",
            targets: ["BLEModel"]
        ),
        .executable(
            name: "ble",
            targets: ["BLECommandLine"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.1.2"),
        .package(url: "https://github.com/Kuniwak/MirrorDiffKit", from: "5.0.1"),
        .package(url: "https://github.com/xcode-actions/swift-signal-handling", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "BLEInternal",
            dependencies: [
                "BLEAssignedNumbers",
            ]
        ),
        .testTarget(
            name: "BLEInternalTests",
            dependencies: [
                "BLEInternal",
            ]
        ),
        .target(
            name: "BLEMacro",
            dependencies: [
                "BLEInternal",
            ]
        ),
        .target(
            name: "BLECommand",
            dependencies: [
                "BLEInternal",
            ]
        ),
        .target(
            name: "BLEModel",
            dependencies: [
                "BLEInternal",
                "CoreBluetoothTestable"
            ]
        ),
        .target(
            name: "BLEMacroCompiler",
            dependencies: [
                "BLEInternal",
                "BLEMacro",
                "BLECommand",
                "BLEAssignedNumbers"
            ]
        ),
        .target(
            name: "BLEInterpreter",
            dependencies: [
                "BLEInternal",
                "BLECommand",
                "CoreBluetoothTestable",
            ]
        ),
        .target(
            name: "CoreBluetoothTestable",
            dependencies: [
                "BLEInternal",
            ]
        ),
        .testTarget(
            name: "BLEMacroTests",
            dependencies: [
                "BLEInternal",
                "BLEMacro",
                "BLEAssignedNumbers",
                "MirrorDiffKit",
            ],
            resources: [
                .copy("Fixtures"),
            ]
        ),
        .executableTarget(
            name: "BLECommandLine",
            dependencies: [
                "BLEInternal",
                "BLEMacro",
                "BLEMacroCompiler",
                "BLECommand",
                "BLEInterpreter",
                "BLEModel",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SignalHandling", package: "swift-signal-handling"),
            ]
        ),
        .target(name: "BLEAssignedNumbers"),
        .executableTarget(
            name: "BLEAssignedNumbersGenerator",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Yams", package: "Yams"),
            ]
        ),
        .testTarget(
            name: "BLEAssignedNumbersGeneratorTests",
            dependencies: [
                "BLEAssignedNumbersGenerator",
                "MirrorDiffKit",
            ],
            resources: [
                .copy("Fixtures"),
            ]
        ),
        .target(
            name: "BLEMacroEasy",
            dependencies: [
                "BLEInternal",
                "BLEMacro",
                "BLEMacroCompiler",
                "BLECommand",
                "BLEInterpreter",
                "CoreBluetoothTestable",
            ]
        ),
        .executableTarget(
            name: "BLEMacroExamples",
            dependencies: [
                "BLEMacroEasy",
            ]
        )
    ]
)
