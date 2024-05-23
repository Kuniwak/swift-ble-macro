import CoreBluetooth


public protocol CharacteristicProtocol {
    // MARK: - Properties from CBAttribute
    var uuid: CBUUID { get }
    
    // MARK: - Properties from CBCharacteristic
    var service: CBService? { get }
    var properties: CBCharacteristicProperties { get }
    var value: Data? { get }
    var descriptors: [CBDescriptor]? { get }
    var isNotifying: Bool { get }
    
    // MARK: - Properties for Internal Use
    var _wrapped: CBCharacteristic? { get }
}


public struct Characteristic: CharacteristicProtocol {
    // MARK: - Properties from CBAttribute
    public var uuid: CBUUID { characteristic.uuid }
    
    // MARK: - Properties from CBCharacteristic
    public var service: CBService? { characteristic.service }
    public var properties: CBCharacteristicProperties { characteristic.properties }
    public var value: Data? { characteristic.value }
    public var descriptors: [CBDescriptor]? { characteristic.descriptors }
    public var isNotifying: Bool { characteristic.isNotifying }
    
    // MARK: - Properties for Internal Use
    private let characteristic: CBCharacteristic
    public var _wrapped: CBCharacteristic? { characteristic }
    
    
    // MARK: - Initializers
    public init(wrapping characteristic: CBCharacteristic) {
        self.characteristic = characteristic
    }
}
