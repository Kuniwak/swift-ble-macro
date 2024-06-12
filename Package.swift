// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "swift-ble-macro",
    platforms: [
        .iOS(.v13),
        .macOS(.v14),
        .watchOS(.v6),
        .visionOS(.v1),
        .tvOS(.v13),
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
            name: "BLEModel",
            targets: ["BLEModel"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Kuniwak/swift-logger.git", .upToNextMajor(from: "1.1.0")),
        .package(url: "https://github.com/Kuniwak/core-bluetooth-testable.git", .upToNextMajor(from: "3.0.0")),
        .package(url: "https://github.com/Kuniwak/swift-ble-assigned-numbers.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/Kuniwak/MirrorDiffKit.git", .upToNextMajor(from: "6.0.0")),
        .package(url: "https://github.com/cezheng/Fuzi.git", .upToNextMajor(from: "3.1.3")),
    ],
    targets: [
        .target(name: "BLEInternal"),
        .testTarget(
            name: "BLEInternalTests",
            dependencies: [
                "BLEInternal",
                .product(name: "Logger", package: "swift-logger"),
                .product(name: "BLEAssignedNumbers", package: "swift-ble-assigned-numbers"),
            ]
        ),
        .target(
            name: "BLEMacro",
            dependencies: [
                "BLEInternal",
                "Fuzi",
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
                .product(name: "Logger", package: "swift-logger"),
                .product(name: "CoreBluetoothTestable", package: "core-bluetooth-testable")
            ]
        ),
        .target(
            name: "BLEMacroCompiler",
            dependencies: [
                "BLEInternal",
                "BLEMacro",
                "BLECommand",
                .product(name: "BLEAssignedNumbers", package: "swift-ble-assigned-numbers"),
            ]
        ),
        .target(
            name: "BLEInterpreter",
            dependencies: [
                "BLEInternal",
                "BLECommand",
                .product(name: "CoreBluetoothTestable", package: "core-bluetooth-testable")
            ]
        ),
        .testTarget(
            name: "BLEMacroTests",
            dependencies: [
                "BLEInternal",
                "BLEMacro",
                "MirrorDiffKit",
                .product(name: "BLEAssignedNumbers", package: "swift-ble-assigned-numbers"),
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
                .product(name: "CoreBluetoothTestable", package: "core-bluetooth-testable")
            ]
        )
    ]
)
