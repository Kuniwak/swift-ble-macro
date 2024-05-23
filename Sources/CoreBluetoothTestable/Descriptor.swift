import CoreBluetooth


public protocol DescriptorProtocol: Equatable {
    // MARK: - Properties from CBAttribute
    var uuid: CBUUID { get }
    
    // MARK: - Properties from CBDescriptor
    var characteristic: (any CharacteristicProtocol)? { get }
    var value: Any? { get }
    
    // MARK: - Properties for Internal Use
    var _wrapped: CBDescriptor? { get }
}


public struct Descriptor: DescriptorProtocol {
    // MARK: - Properties from CBAttribute
    public var uuid: CBUUID { descriptor.uuid }
    
    // MARK: - Properties from CBDescriptor
    public var characteristic: (any CharacteristicProtocol)? { descriptor.characteristic.map(Characteristic.init(wrapping:)) }
    public var value: Any? { descriptor.value }
    
    // MARK: - Properties for Internal Use
    private let descriptor: CBDescriptor
    public var _wrapped: CBDescriptor? { descriptor }
    
    
    // MARK: - Initializers
    public init(wrapping descriptor: CBDescriptor) {
        self.descriptor = descriptor
    }
}
