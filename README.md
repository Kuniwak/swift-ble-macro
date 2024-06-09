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
| `CoreBluetoothTestable` | Defines the testable wrappers of Core Bluetooth.                                                |
| `BLEAssignedNumbers`    | Defines the [BLE assigned numbers](https://www.bluetooth.com/specifications/assigned-numbers/). |
| `BLEModel`              | Defines the convenient state machines for BLE.                                                  |
| `BLECommandLine`        | Defines the command line interface for BLE macros.                                              |


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
// $ git clone https://github.com/Kuniwak/swift-ble-macro
// $ cd swift-ble-macro
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
// $ git clone https://github.com/Kuniwak/swift-ble-macro
// $ cd swift-ble-macro
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


### Run BLE Macros from Command Line

Download binaries from the [releases](https://github.com/Kuniwak/swift-ble-macro/releases) page (Apple Silicon Mac only).

```console
$ # Discover BLE devices
$ ble discover
00000000-0000-0000-0000-000000000000    Example Device 1    -78
11111111-1111-1111-1111-111111111111    Example Device 2    -47
22222222-2222-2222-2222-222222222222    Example Device 3    -54
...

$ # press Ctrl+C to stop scanning

$ # Run a BLE macro
$ ble run path/to/your/ble-macro.xml --uuid 00000000-0000-0000-0000-000000000000

$ # Run a BLE REPL
$ ble repl --uuid 00000000-0000-0000-0000-000000000000
connecting...
connected

(ble) ?
write-command, w, wc    Write to a characteristic without a response
write-descriptor, wd    Write to a descriptor
write-request, req      Write to a characteristic with a response
read, r Read from a characteristic
discovery-service, ds   Discover services
discovery-characteristics, dc   Discover characteristics
discovery-descriptor, dd        Discover descriptors
q, quit Quit the REPL

(ble) dc
180A 2A29 read
180A 2A24 read
D0611E78-BBB4-4591-A5F8-487910AE4366 8667556C-9A37-4C91-84ED-54EE27D90049 write/write/notify/extendedProperties
9FA480E0-4967-4542-9390-D343DC5D04AE AF0BADB1-5B99-43CD-917A-A77BC549E3CC write/write/notify/extendedProperties
180F 2A19 read/notify
1805 2A2B read/notify
1805 2A0F readk

(ble) r 180F 2A19
58
```


License
-------
[MIT License](./LICENSE)