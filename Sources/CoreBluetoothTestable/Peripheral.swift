import Combine
import CoreBluetooth
import BLEInternal


public protocol PeripheralProtocol: Equatable {
    // MARK: - Properties from CBPeer
    var identifier: UUID { get }
    
    // MARK: - Properties from CBPeripheral
    var name: String? { get }
    var state: CBPeripheralState { get }
    var services: [Service]? { get }
    var canSendWriteWithoutResponse: Bool { get }
    
    // MARK: - Methods from CBPeripheral
    func readRSSI()
    func discoverServices(_ serviceUUIDs: [CBUUID]?)
    func discoverIncludedServices(_ includedServiceUUIDs: [CBUUID]?, for service: any ServiceProtocol)
    func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?, for service: any ServiceProtocol)
    func readValue(for characteristic: any CharacteristicProtocol)
    func maximumWriteValueLength(for type: CBCharacteristicWriteType) -> Int
    func writeValue(_ data: Data, for characteristic: any CharacteristicProtocol, type: CBCharacteristicWriteType)
    func setNotifyValue(_ enabled: Bool, for characteristic: any CharacteristicProtocol)
    func discoverDescriptors(for characteristic: any CharacteristicProtocol)
    func readValue(for descriptor: any DescriptorProtocol)
    func writeValue(_ data: Data, for descriptor: any DescriptorProtocol)
    func openL2CAPChannel(_ psm: CBL2CAPPSM)
    
    // MARK: - Publishers from CBPeripheralDelegate
    var didUpdateName: AnyPublisher<String?, Never> { get }
    var didModifyServices: AnyPublisher<[any ServiceProtocol], Never> { get }
    var didUpdateRSSI: AnyPublisher<(rssi: NSNumber?, error: (any Error)?), Never> { get }
    var didReadRSSI: AnyPublisher<(rssi: NSNumber?, error: (any Error)?), Never> { get }
    var didDiscoverServices: AnyPublisher<(services: [any ServiceProtocol]?, error: (any Error)?), Never> { get }
    var didDiscoverIncludedServicesForService: AnyPublisher<(services: [any ServiceProtocol]?, service: any ServiceProtocol, error: (any Error)?), Never> { get }
    var didDiscoverCharacteristicsForService: AnyPublisher<(characteristics: [any CharacteristicProtocol]?, service: any ServiceProtocol, error: (any Error)?), Never> { get }
    var didUpdateValueForCharacteristic: AnyPublisher<(characteristic: any CharacteristicProtocol, error: (any Error)?), Never> { get }
    var didWriteValueForCharacteristic: AnyPublisher<(characteristic: any CharacteristicProtocol, error: (any Error)?), Never> { get }
    var didUpdateNotificationStateForCharacteristic: AnyPublisher<(characteristic: any CharacteristicProtocol, error: (any Error)?), Never> { get }
    var didDiscoverDescriptorsForCharacteristic: AnyPublisher<(descriptors: [any DescriptorProtocol]?, characteristic: any CharacteristicProtocol, error: (any Error)?), Never> { get }
    var didUpdateValueForDescriptor: AnyPublisher<(descriptor: any DescriptorProtocol, error: (any Error)?), Never> { get }
    var isReadyToSendWriteWithoutResponse: AnyPublisher<Bool, Never> { get }
    var didOpenL2CAPChannel: AnyPublisher<(channel: CBL2CAPPSM, error: (any Error)?), Never> { get }
    
    // MARK: - Properties for Internal Use
    var _wrapped: CBPeripheral? { get }
}


extension PeripheralProtocol {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.identifier == rhs.identifier && lhs._wrapped == rhs._wrapped && type(of: lhs) == type(of: rhs)
    }
}


extension PeripheralProtocol {
    public func asAny() -> AnyPeripheral {
        AnyPeripheral(self)
    }
}


public class Peripheral: NSObject, PeripheralProtocol {
    // MARK: - Properties from CBPeer
    public var identifier: UUID { peripheral.identifier }
    
    // MARK: - Properties from CBPeripheral
    public var name: String? { peripheral.name }
    public var state: CBPeripheralState { peripheral.state }
    public var services: [Service]? { peripheral.services.map{ $0.map(Service.init(wrapping:)) } }
    public var canSendWriteWithoutResponse: Bool { peripheral.canSendWriteWithoutResponse }
    
    // MARK: - Publishers from CBPeripheralDelegate
    private let didUpdateNameSubject: PassthroughSubject<String?, Never>
    public let didUpdateName: AnyPublisher<String?, Never>
    
    private let didModifyServicesSubject: PassthroughSubject<[any ServiceProtocol], Never>
    public let didModifyServices: AnyPublisher<[any ServiceProtocol], Never>
    
    private let didUpdateRSSISubject: PassthroughSubject<(rssi: NSNumber?, error: (any Error)?), Never>
    public let didUpdateRSSI: AnyPublisher<(rssi: NSNumber?, error: (any Error)?), Never>
    
    private let didReadRSSISubject: PassthroughSubject<(rssi: NSNumber?, error: (any Error)?), Never>
    public let didReadRSSI: AnyPublisher<(rssi: NSNumber?, error: (any Error)?), Never>
    
    private let didDiscoverServicesSubject: PassthroughSubject<(services: [any ServiceProtocol]?, error: (any Error)?), Never>
    public let didDiscoverServices: AnyPublisher<(services: [any ServiceProtocol]?, error: (any Error)?), Never>
    
    private let didDiscoverIncludedServicesForServiceSubject: PassthroughSubject<(services: [any ServiceProtocol]?, service: any ServiceProtocol, error: (any Error)?), Never>
    public let didDiscoverIncludedServicesForService: AnyPublisher<(services: [any ServiceProtocol]?, service: any ServiceProtocol, error: (any Error)?), Never>
    
    private let didDiscoverCharacteristicsForServiceSubject: PassthroughSubject<(characteristics: [any CharacteristicProtocol]?, service: any ServiceProtocol, error: (any Error)?), Never>
    public let didDiscoverCharacteristicsForService: AnyPublisher<(characteristics: [any CharacteristicProtocol]?, service: any ServiceProtocol, error: (any Error)?), Never>
    
    private let didUpdateValueForCharacteristicSubject: PassthroughSubject<(characteristic: any CharacteristicProtocol, error: (any Error)?), Never>
    public let didUpdateValueForCharacteristic: AnyPublisher<(characteristic: any CharacteristicProtocol, error: (any Error)?), Never>
    
    private let didWriteValueForCharacteristicSubject: PassthroughSubject<(characteristic: any CharacteristicProtocol, error: (any Error)?), Never>
    public let didWriteValueForCharacteristic: AnyPublisher<(characteristic: any CharacteristicProtocol, error: (any Error)?), Never>
    
    private let didUpdateNotificationStateForCharacteristicSubject: PassthroughSubject<(characteristic: any CharacteristicProtocol, error: (any Error)?), Never>
    public let didUpdateNotificationStateForCharacteristic: AnyPublisher<(characteristic: any CharacteristicProtocol, error: (any Error)?), Never>
    
    private let didDiscoverDescriptorsForCharacteristicSubject: PassthroughSubject<(descriptors: [any DescriptorProtocol]?, characteristic: any CharacteristicProtocol, error: (any Error)?), Never>
    public let didDiscoverDescriptorsForCharacteristic: AnyPublisher<(descriptors: [any DescriptorProtocol]?, characteristic: any CharacteristicProtocol, error: (any Error)?), Never>
    
    private let didUpdateValueForDescriptorSubject: PassthroughSubject<(descriptor: any DescriptorProtocol, error: (any Error)?), Never>
    public let didUpdateValueForDescriptor: AnyPublisher<(descriptor: any DescriptorProtocol, error: (any Error)?), Never>
    
    private let isReadyToSendWriteWithoutResponseSubject: PassthroughSubject<Bool, Never>
    public let isReadyToSendWriteWithoutResponse: AnyPublisher<Bool, Never>
    
    private let didOpenL2CAPChannelSubject: PassthroughSubject<(channel: CBL2CAPPSM, error: (any Error)?), Never>
    public let didOpenL2CAPChannel: AnyPublisher<(channel: CBL2CAPPSM, error: (any Error)?), Never>
    
    // MARK: - Properties for Internal Use
    private let peripheral: CBPeripheral
    public var _wrapped: CBPeripheral? { peripheral }
    
    private let logger: LoggerProtocol
    

    // MARK: - Initializers
    private init(wrappingPeripheral peripheral: CBPeripheral, loggingBy logger: LoggerProtocol) {
        guard peripheral.delegate == nil else {
            fatalError("CBPeripheral instance already has a delegate")
        }
        
        self.peripheral = peripheral
        self.logger = logger
        
        let didUpdateNameSubject = PassthroughSubject<String?, Never>()
        self.didUpdateNameSubject = didUpdateNameSubject
        self.didUpdateName = didUpdateNameSubject.eraseToAnyPublisher()
        
        let didModifyServicesSubject = PassthroughSubject<[any ServiceProtocol], Never>()
        self.didModifyServicesSubject = didModifyServicesSubject
        self.didModifyServices = didModifyServicesSubject.eraseToAnyPublisher()
        
        let didUpdateRSSISubject = PassthroughSubject<(rssi: NSNumber?, error: (any Error)?), Never>()
        self.didUpdateRSSISubject = didUpdateRSSISubject
        self.didUpdateRSSI = didUpdateRSSISubject.eraseToAnyPublisher()
        
        let didReadRSSISubject = PassthroughSubject<(rssi: NSNumber?, error: (any Error)?), Never>()
        self.didReadRSSISubject = didReadRSSISubject
        self.didReadRSSI = didReadRSSISubject.eraseToAnyPublisher()
        
        let didDiscoverServicesSubject = PassthroughSubject<(services: [any ServiceProtocol]?, error: (any Error)?), Never>()
        self.didDiscoverServicesSubject = didDiscoverServicesSubject
        self.didDiscoverServices = didDiscoverServicesSubject.eraseToAnyPublisher()
        
        let didDiscoverIncludedServicesForServiceSubject = PassthroughSubject<(services: [any ServiceProtocol]?, service: any ServiceProtocol, error: (any Error)?), Never>()
        self.didDiscoverIncludedServicesForServiceSubject = didDiscoverIncludedServicesForServiceSubject
        self.didDiscoverIncludedServicesForService = didDiscoverIncludedServicesForServiceSubject.eraseToAnyPublisher()
        
        let didDiscoverCharacteristicsForServiceSubject = PassthroughSubject<(characteristics: [any CharacteristicProtocol]?, service: any ServiceProtocol, error: (any Error)?), Never>()
        self.didDiscoverCharacteristicsForServiceSubject = didDiscoverCharacteristicsForServiceSubject
        self.didDiscoverCharacteristicsForService = didDiscoverCharacteristicsForServiceSubject.eraseToAnyPublisher()
        
        let didUpdateValueForCharacteristicSubject = PassthroughSubject<(characteristic: any CharacteristicProtocol, error: (any Error)?), Never>()
        self.didUpdateValueForCharacteristicSubject = didUpdateValueForCharacteristicSubject
        self.didUpdateValueForCharacteristic = didUpdateValueForCharacteristicSubject.eraseToAnyPublisher()
        
        let didWriteValueForCharacteristicSubject = PassthroughSubject<(characteristic: any CharacteristicProtocol, error: (any Error)?), Never>()
        self.didWriteValueForCharacteristicSubject = didWriteValueForCharacteristicSubject
        self.didWriteValueForCharacteristic = didWriteValueForCharacteristicSubject.eraseToAnyPublisher()
        
        let didUpdateNotificationStateForCharacteristicSubject = PassthroughSubject<(characteristic: any CharacteristicProtocol, error: (any Error)?), Never>()
        self.didUpdateNotificationStateForCharacteristicSubject = didUpdateNotificationStateForCharacteristicSubject
        self.didUpdateNotificationStateForCharacteristic = didUpdateNotificationStateForCharacteristicSubject.eraseToAnyPublisher()
        
        let didDiscoverDescriptorsForCharacteristicSubject = PassthroughSubject<(descriptors: [any DescriptorProtocol]?, characteristic: any CharacteristicProtocol, error: (any Error)?), Never>()
        self.didDiscoverDescriptorsForCharacteristicSubject = didDiscoverDescriptorsForCharacteristicSubject
        self.didDiscoverDescriptorsForCharacteristic = didDiscoverDescriptorsForCharacteristicSubject.eraseToAnyPublisher()
        
        let didUpdateValueForDescriptorSubject = PassthroughSubject<(descriptor: any DescriptorProtocol, error: (any Error)?), Never>()
        self.didUpdateValueForDescriptorSubject = didUpdateValueForDescriptorSubject
        self.didUpdateValueForDescriptor = didUpdateValueForDescriptorSubject.eraseToAnyPublisher()
        
        let isReadyToSendWriteWithoutResponseSubject = PassthroughSubject<Bool, Never>()
        self.isReadyToSendWriteWithoutResponseSubject = isReadyToSendWriteWithoutResponseSubject
        self.isReadyToSendWriteWithoutResponse = isReadyToSendWriteWithoutResponseSubject.eraseToAnyPublisher()
        
        let didOpenL2CAPChannelSubject = PassthroughSubject<(channel: CBL2CAPPSM, error: (any Error)?), Never>()
        self.didOpenL2CAPChannelSubject = didOpenL2CAPChannelSubject
        self.didOpenL2CAPChannel = didOpenL2CAPChannelSubject.eraseToAnyPublisher()
        
        super.init()
        
        peripheral.delegate = self
    }
    
    
    public static func from(peripheral: CBPeripheral, logger: LoggerProtocol) -> Peripheral {
        if let delegate = peripheral.delegate {
            if let peripheral = delegate as? Peripheral {
                return peripheral
            }
            fatalError("CBPeripheral instance already has a delegate \(type(of: delegate))")
        }
        return Peripheral(wrappingPeripheral: peripheral, loggingBy: logger)
    }
    
    
    // MARK: - Methods from CBPeripheral
    public func readRSSI() {
        logger.trace()
        peripheral.readRSSI()
    }
    
    
    public func discoverServices(_ serviceUUIDs: [CBUUID]?) {
        logger.trace()
        peripheral.discoverServices(serviceUUIDs)
    }
    
    
    public func discoverIncludedServices(_ includedServiceUUIDs: [CBUUID]?, for service: any ServiceProtocol) {
        logger.trace()
        
        guard let wrapped = service._wrapped else {
            fatalError("Must specify a Service that holds a CBService instance")
        }

        peripheral.discoverIncludedServices(includedServiceUUIDs, for: wrapped)
    }
    
    
    public func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?, for service: any ServiceProtocol) {
        logger.trace()
        
        guard let wrapped = service._wrapped else {
            fatalError("Must specify a Service that holds a CBService instance")
        }

        peripheral.discoverCharacteristics(characteristicUUIDs, for: wrapped)
    }
    
    
    public func readValue(for characteristic: any CharacteristicProtocol) {
        logger.trace()
        
        guard let wrapped = characteristic._wrapped else {
            fatalError("Must specify a Characteristic that holds a CBCharacteristic instance")
        }
        
        peripheral.readValue(for: wrapped)
    }
    
    
    public func maximumWriteValueLength(for type: CBCharacteristicWriteType) -> Int {
        logger.trace()
        return peripheral.maximumWriteValueLength(for: type)
    }
    
    
    public func writeValue(_ data: Data, for characteristic: any CharacteristicProtocol, type: CBCharacteristicWriteType) {
        logger.trace()
        
        guard let wrapped = characteristic._wrapped else {
            fatalError("Must specify a Characteristic that holds a CBCharacteristic instance")
        }
        
        peripheral.writeValue(data, for: wrapped, type: type)
    }
    
    
    public func setNotifyValue(_ enabled: Bool, for characteristic: any CharacteristicProtocol) {
        logger.trace()
        
        guard let wrapped = characteristic._wrapped else {
            fatalError("Must specify a Characteristic that holds a CBCharacteristic instance")
        }
        
        peripheral.setNotifyValue(enabled, for: wrapped)
    }
    
    
    public func discoverDescriptors(for characteristic: any CharacteristicProtocol) {
        logger.trace()
        
        guard let wrapped = characteristic._wrapped else {
            fatalError("Must specify a Characteristic that holds a CBCharacteristic instance")
        }
        
        peripheral.discoverDescriptors(for: wrapped)
    }
    
    
    public func readValue(for descriptor: any DescriptorProtocol) {
        logger.trace()
        
        guard let wrapped = descriptor._wrapped else {
            fatalError("Must specify a Descriptor that holds a any DescriptorProtocol instance")
        }
        
        peripheral.readValue(for: wrapped)
    }
    
    
    public func writeValue(_ data: Data, for descriptor: any DescriptorProtocol) {
        logger.trace()
        
        guard let wrapped = descriptor._wrapped else {
            fatalError("Must specify a Descriptor that holds a any DescriptorProtocol instance")
        }
        
        peripheral.writeValue(data, for: wrapped)
    }
    
    
    public func openL2CAPChannel(_ psm: CBL2CAPPSM) {
        logger.trace()
        peripheral.openL2CAPChannel(psm)
    }
}


extension Peripheral: CBPeripheralDelegate {
    public func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        logger.trace()
        didUpdateNameSubject.send(peripheral.name)
    }
    
    
    public func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        logger.trace()
        didModifyServicesSubject.send(invalidatedServices.map(Service.init(wrapping:)))
    }
    
    
    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        logger.trace()
        didReadRSSISubject.send((RSSI, error))
    }
    
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        logger.trace()
        let services = peripheral.services.map{ $0.map(Service.init(wrapping:)) }
        didDiscoverServicesSubject.send((services, error))
    }
    
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
        logger.trace()
        
        let includedServices = service.includedServices.map{ $0.map(Service.init(wrapping:)) }
        didDiscoverIncludedServicesForServiceSubject.send((includedServices, Service(wrapping: service), error))
    }
    
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        logger.trace()
        
        let characteristics = service.characteristics.map{ $0.map(Characteristic.init(wrapping:)) }
        didDiscoverCharacteristicsForServiceSubject.send((characteristics, Service(wrapping: service), error))
    }
    
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        logger.trace()
        didUpdateValueForCharacteristicSubject.send((Characteristic(wrapping: characteristic), error))
    }
    
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        logger.trace()
        didWriteValueForCharacteristicSubject.send((Characteristic(wrapping: characteristic), error))
    }
}


public struct AnyPeripheral: PeripheralProtocol {
    // MARK: - Properties from CBPeer
    public var identifier: UUID { base.identifier }
    
    // MARK: - Properties from CBPeripheral
    public var name: String? { base.name }
    public var state: CBPeripheralState { base.state }
    public var services: [Service]? { base.services }
    public var canSendWriteWithoutResponse: Bool { base.canSendWriteWithoutResponse }
    
    // MARK: - Methods from CBPeripheral
    public func readRSSI() { base.readRSSI() }
    public func discoverServices(_ serviceUUIDs: [CBUUID]?) { base.discoverServices(serviceUUIDs) }
    public func discoverIncludedServices(_ includedServiceUUIDs: [CBUUID]?, for service: any ServiceProtocol) { base.discoverIncludedServices(includedServiceUUIDs, for: service) }
    public func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?, for service: any ServiceProtocol) { base.discoverCharacteristics(characteristicUUIDs, for: service) }
    public func readValue(for characteristic: any CharacteristicProtocol) { base.readValue(for: characteristic) }
    public func maximumWriteValueLength(for type: CBCharacteristicWriteType) -> Int { base.maximumWriteValueLength(for: type) }
    public func writeValue(_ data: Data, for characteristic: any CharacteristicProtocol, type: CBCharacteristicWriteType) { base.writeValue(data, for: characteristic, type: type) }
    public func setNotifyValue(_ enabled: Bool, for characteristic: any CharacteristicProtocol) { base.setNotifyValue(enabled, for: characteristic) }
    public func discoverDescriptors(for characteristic: any CharacteristicProtocol) { base.discoverDescriptors(for: characteristic) }
    public func readValue(for descriptor: any DescriptorProtocol) { base.readValue(for: descriptor) }
    public func writeValue(_ data: Data, for descriptor: any DescriptorProtocol) { base.writeValue(data, for: descriptor) }
    public func openL2CAPChannel(_ psm: CBL2CAPPSM) { base.openL2CAPChannel(psm) }
    
    // MARK: - Publishers from CBPeripheralDelegate
    public var didUpdateName: AnyPublisher<String?, Never> { base.didUpdateName }
    public var didModifyServices: AnyPublisher<[any ServiceProtocol], Never> { base.didModifyServices }
    public var didUpdateRSSI: AnyPublisher<(rssi: NSNumber?, error: (any Error)?), Never> { base.didUpdateRSSI }
    public var didReadRSSI: AnyPublisher<(rssi: NSNumber?, error: (any Error)?), Never> { base.didReadRSSI }
    public var didDiscoverServices: AnyPublisher<(services: [any ServiceProtocol]?, error: (any Error)?), Never> { base.didDiscoverServices }
    public var didDiscoverIncludedServicesForService: AnyPublisher<(services: [any ServiceProtocol]?, service: any ServiceProtocol, error: (any Error)?), Never> { base.didDiscoverIncludedServicesForService }
    public var didDiscoverCharacteristicsForService: AnyPublisher<(characteristics: [any CharacteristicProtocol]?, service: any ServiceProtocol, error: (any Error)?), Never> { base.didDiscoverCharacteristicsForService }
    public var didUpdateValueForCharacteristic: AnyPublisher<(characteristic: any CharacteristicProtocol, error: (any Error)?), Never> { base.didUpdateValueForCharacteristic }
    public var didWriteValueForCharacteristic: AnyPublisher<(characteristic: any CharacteristicProtocol, error: (any Error)?), Never> { base.didWriteValueForCharacteristic }
    public var didUpdateNotificationStateForCharacteristic: AnyPublisher<(characteristic: any CharacteristicProtocol, error: (any Error)?), Never> { base.didUpdateNotificationStateForCharacteristic }
    public var didDiscoverDescriptorsForCharacteristic: AnyPublisher<(descriptors: [any DescriptorProtocol]?, characteristic: any CharacteristicProtocol, error: (any Error)?), Never> { base.didDiscoverDescriptorsForCharacteristic }
    public var didUpdateValueForDescriptor: AnyPublisher<(descriptor: any DescriptorProtocol, error: (any Error)?), Never> { base.didUpdateValueForDescriptor }
    public var isReadyToSendWriteWithoutResponse: AnyPublisher<Bool, Never> { base.isReadyToSendWriteWithoutResponse }
    public var didOpenL2CAPChannel: AnyPublisher<(channel: CBL2CAPPSM, error: (any Error)?), Never> { base.didOpenL2CAPChannel }
    
    public var _wrapped: CBPeripheral? { base._wrapped }
    
    private let base: any PeripheralProtocol
    
    public init(_ base: any PeripheralProtocol) {
        self.base = base
    }
}
