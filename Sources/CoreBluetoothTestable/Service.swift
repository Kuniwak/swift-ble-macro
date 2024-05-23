import CoreBluetooth


public protocol ServiceProtocol {
    // MARK: - Properties from CBAttribute
    var uuid: CBUUID { get }
    
    // MARK: - Properties from CBService
    var peripheral: CBPeripheral? { get }
    var isPrimary: Bool { get }
    var includedServices: [CBService]? { get }
    var characteristics: [CBCharacteristic]? { get }
    
    // MARK: - Properties for Internal Use
    var _wrapped: CBService? { get }
}


public struct Service: ServiceProtocol {
    // MARK: - Properties from CBAttribute
    public var uuid: CBUUID { service.uuid }
    
    // MARK: - Properties from CBService
    public var peripheral: CBPeripheral? { service.peripheral }
    public var isPrimary: Bool { service.isPrimary }
    public var includedServices: [CBService]? { service.includedServices }
    public var characteristics: [CBCharacteristic]? { service.characteristics }
    
    // MARK: - Properties for Internal Use
    private let service: CBService
    public var _wrapped: CBService? { service }
    
    
    // MARK: - Initializers
    public init(wrapping service: CBService) {
        self.service = service
    }
}
