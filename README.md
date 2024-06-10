swift-ble-macro
===============

This is a simple Swift library that allows you to easily create nRF Connect BLE macros [^1] for your iOS/iPadOS/macOS/watchOS/visionOS/tvOS app.
It is a wrapper around [Core Bluetooth](https://developer.apple.com/documentation/corebluetooth) that allows you to
create macros for BLE devices. It is designed to easily develop Nature Remo compatible BLE macros[^2].

[^1]: https://github.com/NordicSemiconductor/Android-nRF-Connect/blob/54ed2a491567c18c9de91556efb511b9b0bc3ec8/documentation/Macros/README.md
[^2]: https://engineering.nature.global/entry/introduce-device-extension-macro (Japanese)


Installation
------------

Add the following to your `Package.swift` file:

```swift
.package(url: "https://github.com/Kuniwak/swift-ble-macro.git", from: "<version>")
```


### Products

| Product                 | Description                                                                                     |
|:------------------------|:------------------------------------------------------------------------------------------------|
| `BLEMacroEasy`          | Defines the easy interface to execute BLE macros.                                               |
| `BLEMacro`              | Defines the BLE macro XML parser.                                                               |
| `BLEMacroCompiler`      | Defines the BLE macro compiler that compile BLE macro XML to BLE macro IR.                      |
| `BLECommand`            | Defines the BLE macro IR.                                                                       |                     
| `BLEInterpreter`        | Defines the BLE macro interpreter that interprets BLE macro IR.                                 |
| `BLEInternal`           | Defines the utilities for BLE macros.                                                           |
| `BLEModel`              | Defines the convenient state machines for BLE.                                                  |


Supported Macros
----------------

Currently, only the following BLE macro XML elements are supported:

* `<macro>`
* `<assert-service>` 
* `<assert-characteristic>`
* `<assert-descriptor>`
* `<assert-cccd>`
* `<property>`
* `<read>`
* `<assert-value>`
* `<sleep>`
* `<write>`
* `<write-descriptor>`
* `<wait-for-notification>`


Usage
-----

### Run BLE Macros Programmatically
#### Easy Way

If you want to simply run BLE macros, you can use the easy way to run BLE macros.

```swift
import Foundation
import BLEMacroEasy

// You can find your iPhone's UUID by running the following command in Terminal:
// $ git clone https://github.com/Kuniwak/swift-ble-macro-cli
// $ cd swift-ble-macro-cli
// $ swift run ble discover
let myIPhoneUUID = UUID(uuidString: "********-****-****-****-************")!
let myMacro = try String(contentsOf: URL(string: "https://ble-macro.kuniwak.com/iphone/battery-level.xml")!)

try await run(macroXMLString: myMacro, on: myIPhoneUUID) { data in
    // This handler is called when every value read from the peripheral.
    let batteryLevel = Int(data[0])
    print("\(batteryLevel)%")
}
```


#### Advanced Way

You can also use the advanced way to run BLE macros. It is useful when you want to customize the behavior of the BLE macros.

```swift
import Foundation
import os
import BLEMacro
import BLEMacroCompiler
import BLEInterpreter
import BLEInternal
import CoreBluetoothTestable

// You can find your iPhone's UUID by running the following command in Terminal:
// $ git clone https://github.com/Kuniwak/swift-ble-macro-cli
// $ cd swift-ble-macro-cli
// $ swift run ble discover
let myIPhoneUUID = UUID(uuidString: "********-****-****-****-************")!
let myMacro = try String(contentsOf: URL(string: "https://ble-macro.kuniwak.com/iphone/battery-level.xml")!)

let logger = Logger(severity: .debug, writer: OSLogWriter(OSLog(subsystem: "com.example", category: "BLE")))

let macro = try MacroXMLParser.parse(xml: macroXML).get()
let commands = try Compiler(loggingBy: logger).compile(macro: macro).get()
let central = CentralManager(loggingBy: logger)
let centralManagerTasks = CentralManagerTasks(loggingBy: logger, centralManager: central)
let peripheral = try await centralManagerTasks.connect(uuid: peripheralUUID).get()
defer { central.cancelPeripheralConnection(peripheral) }

let interpreter = Interpreter(onPeripheral: peripheral, loggingBy: logger, readHandler) { data in
    // This handler is called when every value read from the peripheral.
    let batteryLevel = Int(data[0])
    print("\(batteryLevel)%")
}
try await interpreter.interpret(commands: commands).get()
```


License
-------
[MIT License](./LICENSE)
