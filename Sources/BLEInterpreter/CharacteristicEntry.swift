import CoreBluetooth
import CoreBluetoothTestable


public struct CharacteristicEntry {
    public let characteristic: any CharacteristicProtocol
    public var descriptors: [CBUUID: any DescriptorProtocol]
    
    public init(characteristic: any CharacteristicProtocol, descriptors: [CBUUID: any DescriptorProtocol]) {
        self.characteristic = characteristic
        self.descriptors = descriptors
    }
}
