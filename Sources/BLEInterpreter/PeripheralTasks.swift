import Combine
import CoreBluetooth
import CoreBluetoothTestable


public protocol PeripheralTasksProtocol {
    func discoverServices(searching serviceUUIDs: [CBUUID]?) async -> Result<[any ServiceProtocol], DiscoveryError>
    func discoverCharacteristics(searching characteristicUUIDs: [CBUUID]?, forServiceUUIDs serviceUUIDs: [CBUUID]?) async -> Result<[any CharacteristicProtocol], DiscoveryError>
    func discoverDescriptors(searching descriptorUUIDs: [CBUUID]?, forCharacteristicUUIDs characteristicUUIDs: [CBUUID]?, inServiceUUIDs serviceUUIDs: [CBUUID]?) async -> Result<[any DescriptorProtocol], DiscoveryError>
}


public class PeripheralTasks: PeripheralTasksProtocol {
    private let peripheral: any PeripheralProtocol
    
    
    public init(peripheral: any PeripheralProtocol) {
        self.peripheral = peripheral
    }
    
    
    public func discoverServices(searching serviceUUIDs: [CBUUID]? = nil) async -> Result<[any ServiceProtocol], DiscoveryError> {
        return await withCheckedContinuation { continuation in
            var cancellable: AnyCancellable? = nil
            cancellable = self.peripheral.didDiscoverServices
                .sink(receiveValue: { resp in
                    defer { cancellable?.cancel() }
                    guard let services = resp.services else {
                        continuation.resume(returning: .failure(.init(wrapping: resp.error!)))
                        return
                    }
                    continuation.resume(returning: .success(services))
                })
            
            self.peripheral.discoverServices(serviceUUIDs)
        }
    }
    
    
    public func discoverCharacteristics(searching characteristicUUIDs: [CBUUID]?, forServiceUUIDs serviceUUIDs: [CBUUID]?) async -> Result<[any CharacteristicProtocol], DiscoveryError> {
        switch await discoverServices(searching: serviceUUIDs) {
        case .failure(let error):
            return .failure(error)
        case .success(let services):
            var characteristics = [any CharacteristicProtocol]()
            for service in services {
                switch await discoverCharacteristics(searching: characteristicUUIDs, forService: service) {
                case .failure(let error):
                    return .failure(error)
                case .success(let newCharacteristics):
                    characteristics.append(contentsOf: newCharacteristics)
                }
            }
            return .success(characteristics)
        }
    }
    
    
    public func discoverCharacteristics(searching characteristicUUIDs: [CBUUID]? = nil, forService service: any ServiceProtocol) async -> Result<[any CharacteristicProtocol], DiscoveryError> {
        return await withCheckedContinuation { continuation in
            var cancellable: AnyCancellable? = nil
            cancellable = self.peripheral.didDiscoverCharacteristicsForService
                .sink(receiveValue: { resp in
                    defer { cancellable?.cancel() }
                    guard let characteristics = resp.characteristics else {
                        continuation.resume(returning: .failure(.init(wrapping: resp.error!)))
                        return
                    }
                    continuation.resume(returning: .success(characteristics))
                })
            
            self.peripheral.discoverCharacteristics(characteristicUUIDs, for: service)
        }
    }
    
    
    public func discoverDescriptors(searching descriptorUUIDs: [CBUUID]?, forCharacteristicUUIDs characteristicUUIDs: [CBUUID]?, inServiceUUIDs serviceUUIDs: [CBUUID]?) async -> Result<[any DescriptorProtocol], DiscoveryError> {
        switch await discoverCharacteristics(searching: characteristicUUIDs, forServiceUUIDs: serviceUUIDs) {
        case .failure(let error):
            return .failure(error)
        case .success(let characteristics):
            var descriptors = [any DescriptorProtocol]()
            for characteristic in characteristics {
                switch await discoverDescriptors(searching: descriptorUUIDs, forCharacteristic: characteristic) {
                case .failure(let error):
                    return .failure(error)
                case .success(let newDescriptors):
                    descriptors.append(contentsOf: newDescriptors)
                }
            }
            return .success(descriptors)
        }
    }
    
    
    public func discoverDescriptors(searching descriptorUUIDs: [CBUUID]? = nil, forCharacteristic characteristic: any CharacteristicProtocol) async -> Result<[any DescriptorProtocol], DiscoveryError> {
        return await withCheckedContinuation { continuation in
            var cancellable: AnyCancellable? = nil
            cancellable = self.peripheral.didDiscoverDescriptorsForCharacteristic
                .sink(receiveValue: { resp in
                    defer { cancellable?.cancel() }
                    guard let descriptors = resp.descriptors else {
                        continuation.resume(returning: .failure(.init(wrapping: resp.error!)))
                        return
                    }
                    continuation.resume(returning: .success(descriptors))
                })
            
            self.peripheral.discoverDescriptors(for: characteristic)
        }
    }
}
