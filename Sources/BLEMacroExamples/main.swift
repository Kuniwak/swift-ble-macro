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
