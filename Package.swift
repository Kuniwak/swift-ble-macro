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
        .library(
            name: "BLEModelStub",
            targets: ["BLEModelStub"]
        ),
        .library(
            name: "BLETasks",
            targets: ["BLETasks"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Kuniwak/swift-logger.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/Kuniwak/core-bluetooth-testable.git", .upToNextMajor(from: "6.1.0")),
        .package(url: "https://github.com/Kuniwak/swift-ble-assigned-numbers.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/Kuniwak/MirrorDiffKit.git", .upToNextMajor(from: "6.0.0")),
        .package(url: "https://github.com/cezheng/Fuzi.git", .upToNextMajor(from: "3.1.3")),
        .package(url: "https://github.com/typelift/SwiftCheck.git", .upToNextMajor(from: "0.12.0")),
    ],
    targets: [
        .target(
            name: "BLEInternal",
            dependencies: []
        ),
        .testTarget(
            name: "BLEInternalTests",
            dependencies: [
                .bleInternal,
                .logger,
                .bleAssignedNumbers,
            ]
        ),
        .target(
            name: "BLEMacro",
            dependencies: [
                .bleInternal,
                .fuzi,
            ]
        ),
        .target(
            name: "BLEMacroStub",
            dependencies: [
                .bleMacro,
                .swiftCheck,
            ]
        ),
        .target(
            name: "BLECommand",
            dependencies: [
                .bleInternal,
            ]
        ),
        .target(
            name: "BLEModel",
            dependencies: [
                .bleInternal,
                .logger,
                .coreBluetoothTestable,
            ]
        ),
        .target(
            name: "BLEModelStub",
            dependencies: [
                .bleModel,
                .bleInternal,
                .logger,
                .coreBluetoothTestable,
                .coreBluetoothStub,
            ]
        ),
        .target(
            name: "BLEMacroCompiler",
            dependencies: [
                .bleInternal,
                .bleMacro,
                .bleCommand,
                .bleAssignedNumbers,
            ]
        ),
        .target(
            name: "BLETasks",
            dependencies: [
                .bleInternal,
                .logger,
                .coreBluetoothTestable,
            ]
        ),
        .target(
            name: "BLEInterpreter",
            dependencies: [
                .logger,
                .bleInternal,
                .bleTasks,
                .bleCommand,
                .coreBluetoothTestable,
            ]
        ),
        .testTarget(
            name: "BLEMacroTests",
            dependencies: [
                .bleInternal,
                .bleMacro,
                .bleMacroStub,
                .bleAssignedNumbers,
                .mirrorDiffKit,
                .swiftCheck,
            ],
            resources: [
                .copy("Fixtures"),
            ]
        ),
        .target(
            name: "BLEMacroEasy",
            dependencies: [
                .bleInternal,
                .bleMacro,
                .bleMacroCompiler,
                .bleCommand,
                .bleTasks,
                .bleInterpreter,
                .coreBluetoothTestable,
            ]
        )
    ]
)


private extension Target.Dependency {
    static let bleInternal: Self = "BLEInternal"
    static let bleMacro: Self = "BLEMacro"
    static let bleMacroStub: Self = "BLEMacroStub"
    static let bleMacroCompiler: Self = "BLEMacroCompiler"
    static let bleCommand: Self = "BLECommand"
    static let bleInterpreter: Self = "BLEInterpreter"
    static let bleModel: Self = "BLEModel"
    static let bleTasks: Self = "BLETasks"
    static let fuzi: Self = "Fuzi"
    static let mirrorDiffKit: Self = "MirrorDiffKit"
    static let logger: Self = .product(name: "Logger", package: "swift-logger")
    static let coreBluetoothTestable: Self = .product(name: "CoreBluetoothTestable", package: "core-bluetooth-testable")
    static let coreBluetoothStub: Self = .product(name: "CoreBluetoothStub", package: "core-bluetooth-testable")
    static let bleAssignedNumbers: Self = .product(name: "BLEAssignedNumbers", package: "swift-ble-assigned-numbers")
    static let swiftCheck: Self = "SwiftCheck"
}
