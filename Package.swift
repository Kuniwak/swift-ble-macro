// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "BluetoothLEMacroKit",
    platforms: [
        .iOS(.v12),
        .macOS(.v14),
        .watchOS(.v4),
        .visionOS(.v1),
        .tvOS(.v12),
    ],
    products: [
        .library(
            name: "BluetoothLEMacroKit",
            targets: ["BluetoothLEMacroKit"]),
    ],
    targets: [
        .target(
            name: "BluetoothLEMacroKit"),
        .testTarget(
            name: "BluetoothLEMacroKitTests",
            dependencies: ["BluetoothLEMacroKit"]),
    ]
)
