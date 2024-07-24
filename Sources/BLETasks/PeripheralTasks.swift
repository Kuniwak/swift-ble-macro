import Combine
import CoreBluetooth
import CoreBluetoothTestable


public protocol PeripheralTasksProtocol: AnyActor {
    func discoverServices(searching serviceUUIDs: [CBUUID]?) async -> Result<[any ServiceProtocol], PeripheralTaskFailure>
    func discoverService(searching uuid: CBUUID) async -> Result<any ServiceProtocol, PeripheralTaskFailure>
    func discoverCharacteristics(searching characteristicUUIDs: [CBUUID]?, forServiceUUIDs serviceUUIDs: [CBUUID]?) async -> Result<[any CharacteristicProtocol], PeripheralTaskFailure>
    func discoverCharacteristic(searching uuid: CBUUID, forService service: any ServiceProtocol) async -> Result<any CharacteristicProtocol, PeripheralTaskFailure>
    func discoverDescriptors(searching descriptorUUIDs: [CBUUID]?, forCharacteristicUUIDs characteristicUUIDs: [CBUUID]?, inServiceUUIDs serviceUUIDs: [CBUUID]?) async -> Result<[any DescriptorProtocol], PeripheralTaskFailure>
    func discoverDescriptor(searching uuid: CBUUID, forCharacteristic characteristic: any CharacteristicProtocol) async -> Result<any DescriptorProtocol, PeripheralTaskFailure>
    func write(forCharacteristic characteristic: any CharacteristicProtocol, value: Data, writeType: CBCharacteristicWriteType) async -> Result<Void, PeripheralTaskFailure>
    func write(forDescriptor descriptor: any DescriptorProtocol, onCharacteristic characteristic: any CharacteristicProtocol, value: Data) async -> Result<Void, PeripheralTaskFailure>
    func read(fromCharacteristic characteristic: any CharacteristicProtocol) async -> Result<Data, PeripheralTaskFailure>
    func read(fromDescriptor descriptor: any DescriptorProtocol) async -> Result<Any, PeripheralTaskFailure>
    func waitForNotification(onCharacteristic characteristic: any CharacteristicProtocol) async -> Result<Void, PeripheralTaskFailure>
}


public struct PeripheralTaskFailure: Error, Equatable, Codable, Sendable, CustomStringConvertible {
    public let description: String
    
    
    public init(_ description: String) {
        self.description = description
    }
    
    
    public init(wrapping error: any Error) {
        self.description = "\(error)"
    }
    
    
    public init(wrapping error: (any Error)?) {
        self.description = error.map { "\($0)" } ?? "nil"
    }
}



public final actor PeripheralTasks: PeripheralTasksProtocol {
    private let peripheral: any PeripheralProtocol
    
    
    public init(peripheral: any PeripheralProtocol) {
        self.peripheral = peripheral
    }
    
    
    public func discoverServices(searching serviceUUIDs: [CBUUID]? = nil) async -> Result<[any ServiceProtocol], PeripheralTaskFailure> {
        return await withCheckedContinuation { continuation in
            var cancellable: AnyCancellable? = nil
            cancellable = self.peripheral.didDiscoverServices
                .sink(receiveValue: { resp in
                    defer { cancellable?.cancel() }
                    if let services = resp.services {
                        continuation.resume(returning: .success(services))
                    } else {
                        continuation.resume(returning: .failure(.init(wrapping: resp.error)))
                    }
                })
            
            self.peripheral.discoverServices(serviceUUIDs)
        }
    }
    
    
    public func discoverService(searching uuid: CBUUID) async -> Result<any ServiceProtocol, PeripheralTaskFailure> {
        await discoverServices(searching: [uuid])
            .flatMap { services in
                guard let service = services.first(where: { $0.uuid == uuid }) else {
                    return .failure(.init("Service \(uuid) not found"))
                }
                return .success(service)
            }
    }
    
    
    public func discoverCharacteristics(searching characteristicUUIDs: [CBUUID]?, forServiceUUIDs serviceUUIDs: [CBUUID]?) async -> Result<[any CharacteristicProtocol], PeripheralTaskFailure> {
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
    
    
    public func discoverCharacteristics(searching characteristicUUIDs: [CBUUID]? = nil, forService service: any ServiceProtocol) async -> Result<[any CharacteristicProtocol], PeripheralTaskFailure> {
        return await withCheckedContinuation { continuation in
            var cancellable: AnyCancellable? = nil
            cancellable = self.peripheral.didDiscoverCharacteristicsForService
                .sink(receiveValue: { resp in
                    guard resp.service.uuid == service.uuid else { return }
                    defer { cancellable?.cancel() }
                    
                    if let characteristics = resp.characteristics {
                        continuation.resume(returning: .success(characteristics))
                    } else {
                        continuation.resume(returning: .failure(.init(wrapping: resp.error)))
                    }
                })
            
            self.peripheral.discoverCharacteristics(characteristicUUIDs, for: service)
        }
    }
    
    
    public func discoverCharacteristic(searching uuid: CBUUID, forService service: any ServiceProtocol) async -> Result<any CharacteristicProtocol, PeripheralTaskFailure> {
        
        await discoverCharacteristics(searching: [uuid], forService: service)
            .flatMap { characteristics in
                guard let characteristic = characteristics.first(where: { $0.uuid == uuid }) else {
                    return .failure(.init("Characteristic \(uuid) not found"))
                }
                return .success(characteristic)
            }
    }
    
    
    public func discoverDescriptors(searching descriptorUUIDs: [CBUUID]?, forCharacteristicUUIDs characteristicUUIDs: [CBUUID]?, inServiceUUIDs serviceUUIDs: [CBUUID]?) async -> Result<[any DescriptorProtocol], PeripheralTaskFailure> {
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
    
    
    public func discoverDescriptors(searching descriptorUUIDs: [CBUUID]? = nil, forCharacteristic characteristic: any CharacteristicProtocol) async -> Result<[any DescriptorProtocol], PeripheralTaskFailure> {
        return await withCheckedContinuation { continuation in
            var cancellable: AnyCancellable? = nil
            cancellable = self.peripheral.didDiscoverDescriptorsForCharacteristic
                .sink(receiveValue: { resp in
                    guard resp.characteristic.uuid == characteristic.uuid && resp.characteristic.service?.uuid == characteristic.service?.uuid else { return }
                    
                    defer { cancellable?.cancel() }
                    
                    if let descriptors = resp.descriptors {
                        continuation.resume(returning: .success(descriptors))
                    } else {
                        continuation.resume(returning: .failure(.init(wrapping: resp.error)))
                    }
                })
            
            self.peripheral.discoverDescriptors(for: characteristic)
        }
    }
    
    
    public func discoverDescriptor(searching uuid: CBUUID, forCharacteristic characteristic: any CharacteristicProtocol) async -> Result<any DescriptorProtocol, PeripheralTaskFailure> {
        await discoverDescriptors(searching: [uuid], forCharacteristic: characteristic)
            .flatMap { descriptors in
                guard let descriptor = descriptors.first(where: { $0.uuid == uuid }) else {
                    return .failure(.init("Descriptor \(uuid) not found"))
                }
                return .success(descriptor)
            }
    }
    
    
    public func write(forCharacteristic characteristic: any CharacteristicProtocol, value: Data, writeType: CBCharacteristicWriteType) async -> Result<Void, PeripheralTaskFailure> {
        return await withCheckedContinuation { continuation in
            switch writeType {
            case .withResponse:
                var cancellable: AnyCancellable? = nil
                cancellable = peripheral.didWriteValueForCharacteristic
                    .sink(receiveValue: { resp in
                        guard resp.characteristic.uuid == characteristic.uuid && resp.characteristic.service?.uuid == characteristic.service?.uuid else { return }
                        
                        defer { cancellable?.cancel() }

                        if let error = resp.error {
                            continuation.resume(returning: .failure(.init(wrapping: error)))
                        } else {
                            continuation.resume(returning: .success(()))
                        }
                    })
                peripheral.writeValue(value, for: characteristic, type: .withResponse)
            case .withoutResponse:
                peripheral.writeValue(value, for: characteristic, type: .withoutResponse)
                continuation.resume(returning: .success(()))
            default:
                continuation.resume(returning: .failure(.init("Unsupported write type: \(writeType)")))
            }
        }
    }
    
    
    public func write(forDescriptor descriptor: any DescriptorProtocol, onCharacteristic characteristic: any CharacteristicProtocol, value: Data) async -> Result<Void, PeripheralTaskFailure> {
        // NOTE: > You can’t use this method to write the value of a client configuration descriptor
        //       > (represented by the CBUUIDClientCharacteristicConfigurationString constant),
        //       > which describes the configuration of notification or indications for a characteristic’s value.
        //       > If you want to manage notifications or indications for a characteristic’s value,
        //       > you must use the setNotifyValue(_:for:) method instead.
        // SEE: https://developer.apple.com/documentation/corebluetooth/cbperipheral/writevalue(_:for:)
        if descriptor.uuid.uuidString == CBUUIDClientCharacteristicConfigurationString {
            return await withCheckedContinuation { continuation in
                var cancellable: AnyCancellable? = nil
                cancellable = peripheral.didUpdateNotificationStateForCharacteristic
                    .sink(receiveValue: { resp in
                        guard resp.characteristic.uuid == characteristic.uuid && resp.characteristic.service?.uuid == characteristic.service?.uuid else { return }
                        
                        defer { cancellable?.cancel() }

                        if let error = resp.error {
                            continuation.resume(returning: .failure(.init(wrapping: error)))
                        } else {
                            continuation.resume(returning: .success(()))
                        }
                    })
                peripheral.setNotifyValue(value == Data([0x01]), for: characteristic)
            }
        } else {
            return await withCheckedContinuation { continuation in
                var cancellable: AnyCancellable? = nil
                cancellable = peripheral.didWriteValueForDescriptor
                    .sink(receiveValue: { resp in
                        guard resp.descriptor.uuid == descriptor.uuid && resp.descriptor.characteristic?.uuid == characteristic.uuid && resp.descriptor.characteristic?.service?.uuid == characteristic.service?.uuid else { return }
                        
                        defer { cancellable?.cancel() }

                        if let error = resp.error {
                            continuation.resume(returning: .failure(.init(wrapping: error)))
                        } else {
                            continuation.resume(returning: .success(()))
                        }
                    })
                peripheral.writeValue(value, for: descriptor)
            }
        }
    }
    
    
    public func read(fromCharacteristic characteristic: any CharacteristicProtocol) async -> Result<Data, PeripheralTaskFailure> {
        return await withCheckedContinuation { continuation in
            var cancellable: AnyCancellable? = nil
            cancellable = peripheral.didUpdateValueForCharacteristic
                .sink(receiveValue: { resp in
                    guard resp.characteristic.uuid == characteristic.uuid && resp.characteristic.service?.uuid == characteristic.service?.uuid else { return }
                    
                    defer { cancellable?.cancel() }

                    if let error = resp.error {
                        continuation.resume(returning: .failure(.init(wrapping: error)))
                        return
                    }

                    guard let value = resp.characteristic.value else {
                        continuation.resume(returning: .failure(.init("Read but value is nil")))
                        return
                    }

                    continuation.resume(returning: .success(value))
                })
            peripheral.readValue(for: characteristic)
        }
    }
    
    
    public func read(fromDescriptor descriptor: any DescriptorProtocol) async -> Result<Any, PeripheralTaskFailure> {
        return await withCheckedContinuation { continuation in
            var cancellable: AnyCancellable? = nil
            cancellable = peripheral.didUpdateValueForDescriptor
                .sink(receiveValue: { resp in
                    guard resp.descriptor.uuid == descriptor.uuid && resp.descriptor.characteristic?.uuid == descriptor.characteristic?.uuid && resp.descriptor.characteristic?.service?.uuid == descriptor.characteristic?.service?.uuid else { return }
                    
                    defer { cancellable?.cancel() }

                    if let error = resp.error {
                        continuation.resume(returning: .failure(.init(wrapping: error)))
                        return
                    }

                    guard let value = resp.descriptor.value else {
                        continuation.resume(returning: .failure(.init("Read but value is nil")))
                        return
                    }

                    continuation.resume(returning: .success(value))
                })
            peripheral.readValue(for: descriptor)
        }
    }
    
    
    public func waitForNotification(onCharacteristic characteristic: any CharacteristicProtocol) async -> Result<Void, PeripheralTaskFailure> {
        return await withCheckedContinuation { continuation in
            var cancellable: AnyCancellable? = nil
            cancellable = peripheral.didUpdateValueForCharacteristic
                .sink(receiveValue: { resp in
                    guard resp.characteristic.uuid == characteristic.uuid && resp.characteristic.service?.uuid == characteristic.service?.uuid else { return }
                    
                    defer { cancellable?.cancel() }

                    if let error = resp.error {
                        continuation.resume(returning: .failure(.init(wrapping: error)))
                        return
                    }

                    continuation.resume(returning: .success(()))
                })
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
}
