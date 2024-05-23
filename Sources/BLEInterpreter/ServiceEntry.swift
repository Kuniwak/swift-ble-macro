import CoreBluetooth
import CoreBluetoothTestable


public struct ServiceEntry {
    public let service: any ServiceProtocol
    public var characteristics: [CBUUID: CharacteristicEntry]
    
    public init(service: any ServiceProtocol, characteristics: [CBUUID: CharacteristicEntry]) {
        self.service = service
        self.characteristics = characteristics
    }
}
