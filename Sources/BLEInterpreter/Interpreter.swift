import Combine
import CoreBluetooth
import CoreBluetoothTestable
import BLEInternal
import BLECommand


public protocol InterpreterProtocol {
    var environment: Environment { get }
    func interpret(commands: [Command]) async -> Result<Void, CommandExecutionFailure>
    func interpret(command: Command) async -> Result<Void, CommandExecutionFailure>
    func assertService(_ cmd: AssertService) async -> Result<ServiceEntry, CommandExecutionFailure>
    func assertCharacteristic(_ cmd: AssertCharacteristic) async -> Result<(serviceEntry: ServiceEntry, characteristicEntry: CharacteristicEntry), CommandExecutionFailure>
    func assertDescriptor(_ cmd: AssertDescriptor) async -> Result<(serviceEntry: ServiceEntry, characteristicEntry: CharacteristicEntry, descriptor: any DescriptorProtocol), CommandExecutionFailure>
    func assertProperty(_ cmd: AssertProperty) async -> Result<Void, CommandExecutionFailure>
    func assertValue(_ cmd: AssertValue) async -> Result<Void, CommandExecutionFailure>
    func write(_ cmd: Write) async -> Result<Void, CommandExecutionFailure>
    func writeDescriptor(_ cmd: WriteDescriptor) async -> Result<Void, CommandExecutionFailure>
    func read(_ cmd: Read) async -> Result<Data, CommandExecutionFailure>
    func sleep(_ cmd: Sleep) async -> Result<Void, CommandExecutionFailure>
    func waitForNotification(_ cmd: WaitForNotification) async -> Result<Void, CommandExecutionFailure>
}


open class Interpreter: InterpreterProtocol {
    public private(set) var environment: Environment
    public let peripheral: any PeripheralProtocol
    private let logger: any LoggerProtocol
    private let timeout: TimeInterval = 5
    private let readHandler: ((Data) -> Void)?

    
    public init(startsWith environment: Environment, onPeripheral peripheral: any PeripheralProtocol, loggingBy logger: any LoggerProtocol, _ readHandler: ((Data) -> Void)? = nil) {
        self.environment = environment
        self.peripheral = peripheral
        self.logger = logger
        self.readHandler = readHandler
    }
    
    
    public init(onPeripheral peripheral: any PeripheralProtocol, loggingBy logger: any LoggerProtocol, _ readHandler: ((Data) -> Void)? = nil) {
        self.environment = Environment(services: [:], register: nil)
        self.peripheral = peripheral
        self.logger = logger
        self.readHandler = readHandler
    }
    
    
    open func interpret(commands: [Command]) async -> Result<Void, CommandExecutionFailure> {
        logger.trace()
        var index = 0
        while index < commands.count {
            switch await interpret(command: commands[index]) {
            case .success:
                index += 1
            case .failure(let error):
                return .failure(error)
            }
        }
        return .success(())
    }
    
    
    open func interpret(command: Command) async -> Result<Void, CommandExecutionFailure> {
        switch command {
        case .assertService(let cmd):
            switch await assertService(cmd) {
            case .failure(let error):
                return .failure(error)
            case .success:
                return .success(())
            }
        case .assertCharacteristic(let cmd):
            switch await assertCharacteristic(cmd) {
            case .failure(let error):
                return .failure(error)
            case .success:
                return .success(())
            }
        case .assertDescriptor(let cmd):
            switch await assertDescriptor(cmd) {
            case .failure(let error):
                return .failure(error)
            case .success:
                return .success(())
            }
        case .assertProperty(let cmd):
            switch await assertProperty(cmd) {
            case .failure(let error):
                return .failure(error)
            case .success:
                return .success(())
            }
        case .assertValue(let cmd):
            switch await assertValue(cmd) {
            case .failure(let error):
                return .failure(error)
            case .success:
                return .success(())
            }
        case .write(let cmd):
            switch await write(cmd) {
            case .failure(let error):
                return .failure(error)
            case .success:
                return .success(())
            }
        case .writeDescriptor(let cmd):
            switch await writeDescriptor(cmd) {
            case .failure(let error):
                return .failure(error)
            case .success:
                return .success(())
            }
        case .read(let cmd):
            switch await read(cmd) {
            case .failure(let error):
                return .failure(error)
            case .success:
                return .success(())
            }
        case .sleep(let cmd):
            switch await sleep(cmd) {
            case .failure(let error):
                return .failure(error)
            case .success:
                return .success(())
            }
        case .waitForNotification(let cmd):
            switch await waitForNotification(cmd) {
            case .failure(let error):
                return .failure(error)
            case .success:
                return .success(())
            }
        }
    }
    
    
    open func assertService(_ cmd: AssertService) async -> Result<ServiceEntry, CommandExecutionFailure> {
        logger.trace()
        
        if let serviceEntry = environment.serviceEntries[cmd.serviceUUID] {
            logger.debug("service \(cmd.serviceUUID) already found")
            return .success(serviceEntry)
        }
        
        logger.debug("discovering service \(cmd.serviceUUID)")
        let result = await Tasks.timeout(duration: timeout) {
            await self.waitService(uuid: cmd.serviceUUID)
        }
        switch result {
        case .failure(let error):
            return .failure(.init(wrapping: error))
        case .success(.failure(let error)):
            return .failure(error)
        case .success(.success(let service)):
            let serviceEntry = ServiceEntry(service: service, characteristics: [:])
            self.environment.serviceEntries[cmd.serviceUUID] = serviceEntry
            return .success(serviceEntry)
        }
    }
    
    
    public func waitService(uuid: CBUUID) async -> Result<any ServiceProtocol, CommandExecutionFailure> {
        let logger = self.logger
        logger.trace()

        return await withCheckedContinuation { continuation in
            var cancellables = Set<AnyCancellable>()
            peripheral.didDiscoverServices
                .sink(receiveValue: { resp in
                    defer { cancellables.removeAll() }
                    
                    guard let services = resp.services else {
                        logger.error("failed to discover services: \(resp.error == nil ? "nil" : "\(resp.error!)")")
                        continuation.resume(returning: .failure(.init(wrapping: resp.error)))
                        return
                    }
                    
                    guard let service = services.first(where: { $0.uuid == uuid }) else {
                        logger.debug("service \(uuid) not found")
                        continuation.resume(returning: .failure(.init(description: "Service \(uuid) not found")))
                        return
                    }
                    
                    logger.debug("service \(uuid) found")
                    continuation.resume(returning: .success(service))
                })
                .store(in: &cancellables)
            peripheral.discoverServices([uuid])
        }
    }
    
    
    open func assertCharacteristic(_ cmd: AssertCharacteristic) async -> Result<(serviceEntry: ServiceEntry, characteristicEntry: CharacteristicEntry), CommandExecutionFailure> {
        logger.trace()
        
        switch await assertService(.init(serviceUUID: cmd.serviceUUID)) {
        case .failure(let error):
            return .failure(error)
        case .success(let serviceEntry):
            if let characteristicEntry = serviceEntry.characteristics[cmd.characteristicUUID] {
                logger.debug("characteristic \(cmd.characteristicUUID) already found")
                return .success((serviceEntry, characteristicEntry))
            }
            
            logger.debug("discovering characteristic \(cmd.characteristicUUID)")
            
            let result = await Tasks.timeout(duration: timeout) {
                await self.waitCharacteristic(for: cmd.characteristicUUID, with: serviceEntry.service)
            }
            switch result {
            case .failure(let error):
                return .failure(.init(wrapping: error))
            case .success(.failure(let error)):
                return .failure(error)
            case .success(.success(let characteristic)):
                var newServiceEntry = serviceEntry
                let characteristicEntry = CharacteristicEntry(characteristic: characteristic, descriptors: [:])
                newServiceEntry.characteristics[cmd.characteristicUUID] = characteristicEntry
                environment.serviceEntries[cmd.serviceUUID] = newServiceEntry
                return .success((newServiceEntry, characteristicEntry))
            }
        }
    }
    
    
    public func waitCharacteristic(for uuid: CBUUID, with service: any ServiceProtocol) async -> Result<any CharacteristicProtocol, CommandExecutionFailure> {
        let logger = self.logger
        logger.trace()
        
        return await withCheckedContinuation { continuation in
            var subscription: AnyCancellable?
            subscription = peripheral.didDiscoverCharacteristicsForService
                .sink(receiveValue: { resp in
                    defer { subscription?.cancel() }
                    
                    guard let characteristics = resp.characteristics else {
                        logger.error("failed to discover characteristics: \(resp.error == nil ? "nil" : "\(resp.error!)")")
                        continuation.resume(returning: .failure(.init(wrapping: resp.error)))
                        return
                    }
                    
                    guard let characteristic = characteristics.first(where: { $0.uuid == uuid }) else {
                        logger.debug("characteristic \(uuid) not found")
                        continuation.resume(returning: .failure(.init(description: "Characteristic \(uuid) not found")))
                        return
                    }
                    
                    logger.debug("characteristic \(uuid) found")
                    continuation.resume(returning: .success(characteristic))
                })
            peripheral.discoverCharacteristics([uuid], for: service)
        }
    }
    
    
    open func assertDescriptor(_ cmd: AssertDescriptor) async -> Result<(serviceEntry: ServiceEntry, characteristicEntry: CharacteristicEntry, descriptor: any DescriptorProtocol), CommandExecutionFailure> {
        logger.trace()
        
        switch await assertCharacteristic(.init(characteristicUUID: cmd.characteristicUUID, serviceUUID: cmd.serviceUUID)) {
        case .failure(let error):
            return .failure(error)
        case .success((serviceEntry: let serviceEntry, characteristicEntry: let characteristicEntry)):
            if let descriptor = characteristicEntry.descriptors[cmd.descriptorUUID] {
                logger.debug("Descriptor \(cmd.descriptorUUID) already found")
                return .success((serviceEntry: serviceEntry, characteristicEntry: characteristicEntry, descriptor: descriptor))
            }
            
            logger.debug("Discovering descriptor \(cmd.descriptorUUID)")
            let result = await Tasks.timeout(duration: timeout) {
                await self.waitDescriptor(for: cmd.descriptorUUID, withCharacteristic: characteristicEntry.characteristic, withService: serviceEntry.service)
            }
            switch result {
            case .failure(let error):
                return .failure(.init(wrapping: error))
            case .success(.failure(let error)):
                return .failure(error)
            case .success(.success(let descriptor)):
                var newCharacteristicEntry = characteristicEntry
                newCharacteristicEntry.descriptors[cmd.descriptorUUID] = descriptor
                var newServiceEntry = serviceEntry
                newServiceEntry.characteristics[cmd.characteristicUUID] = newCharacteristicEntry
                environment.serviceEntries[cmd.serviceUUID] = newServiceEntry
                return .success((newServiceEntry, newCharacteristicEntry, descriptor))
            }
        }
    }
    
    
    public func waitDescriptor(for uuid: CBUUID, withCharacteristic characteristic: any CharacteristicProtocol, withService service: any ServiceProtocol) async -> Result<any DescriptorProtocol, CommandExecutionFailure> {
        logger.trace()
        
        return await withCheckedContinuation { continuation in
            var cancellables = Set<AnyCancellable>()
            peripheral.didDiscoverDescriptorsForCharacteristic
                .sink(receiveValue: { [weak self] resp in
                    defer { cancellables.removeAll() }
                    
                    guard let self else { return }

                    guard let descriptors = resp.descriptors else {
                        self.logger.error("failed to discover descriptors: \(resp.error == nil ? "nil" : "\(resp.error!)")")
                        continuation.resume(returning: .failure(.init(wrapping: resp.error)))
                        return
                    }
                    
                    guard let descriptor = descriptors.first(where: { $0.uuid == uuid }) else {
                        self.logger.debug("descriptor \(uuid) not found")
                        continuation.resume(returning: .failure(.init(description: "Descriptor \(uuid) not found")))
                        return
                    }
                    
                    self.logger.debug("descriptor \(uuid) found")
                    continuation.resume(returning: .success(descriptor))
                })
                .store(in: &cancellables)
            peripheral.discoverDescriptors(for: characteristic)
        }
    }

    
    open func assertProperty(_ cmd: AssertProperty) async -> Result<Void, CommandExecutionFailure> {
        logger.trace()
        
        switch await assertCharacteristic(.init(characteristicUUID: cmd.characteristicUUID, serviceUUID: cmd.serviceUUID)) {
        case .failure(let error):
            return .failure(error)
        case .success((_, let characteristicEntry)):
            guard characteristicEntry.characteristic.properties.contains(cmd.property) else {
                return .failure(CommandExecutionFailure(description: "\(cmd.characteristicUUID.uuidString) does not have a property \(cmd.property)"))
            }
            
            // TODO: Check requirement
            
            return .success(())
        }
    }
    
    
    open func write(_ cmd: Write) async -> Result<Void, CommandExecutionFailure> {
        logger.trace()
        
        switch await assertCharacteristic(.init(characteristicUUID: cmd.characteristicUUID, serviceUUID: cmd.serviceUUID)) {
        case .failure(let error):
            return .failure(error)
        case .success((_, let characteristicEntry)):
            return await withCheckedContinuation { continuation in
                switch cmd.writeType {
                case .withResponse:
                    var cancellables = Set<AnyCancellable>()
                    peripheral.didWriteValueForCharacteristic
                        .sink(receiveValue: { [weak self] resp in
                            defer { cancellables.removeAll() }
                            guard let self else { return }
                            
                            if let error = resp.error {
                                self.logger.error("failed to write value: \(error)")
                                continuation.resume(returning: .failure(.init(wrapping: error)))
                                return
                            }
                            
                            self.logger.debug("value written \(HexEncoding.upper.encode(data: cmd.value))")
                            continuation.resume(returning: .success(()))
                        })
                        .store(in: &cancellables)
                    peripheral.writeValue(cmd.value, for: characteristicEntry.characteristic, type: .withResponse)
                case .withoutResponse:
                    peripheral.writeValue(cmd.value, for: characteristicEntry.characteristic, type: .withoutResponse)
                    continuation.resume(returning: .success(()))
                default:
                    continuation.resume(returning: .failure(.init(description: "unsupported write type: \(cmd.writeType)")))
                }
            }
        }
    }
    
    
    open func writeDescriptor(_ cmd: WriteDescriptor) async -> Result<Void, CommandExecutionFailure> {
        logger.trace()
        
        switch await assertDescriptor(.init(descriptorUUID: cmd.descriptorUUID, characteristicUUID: cmd.characteristicUUID, serviceUUID: cmd.serviceUUID)) {
        case .failure(let error):
            return .failure(error)
        case .success((_, _, let descriptor)):
            peripheral.writeValue(cmd.value, for: descriptor)
            return .success(())
        }
    }
    
    
    open func read(_ cmd: Read) async -> Result<Data, CommandExecutionFailure> {
        logger.trace()
        
        switch await assertCharacteristic(.init(characteristicUUID: cmd.characteristicUUID, serviceUUID: cmd.serviceUUID)) {
        case .failure(let error):
            return .failure(error)
        case .success((_, let characteristicEntry)):
            return await withCheckedContinuation { continuation in
                var cancellables = Set<AnyCancellable>()
                peripheral.didUpdateValueForCharacteristic
                    .sink(receiveValue: { [weak self] resp in
                        defer { cancellables.removeAll() }
                        guard let self else { return }
                        
                        if let error = resp.error {
                            self.logger.error("failed to update value: \(error)")
                            continuation.resume(returning: .failure(.init(wrapping: error)))
                            return
                        }

                        guard let value = resp.characteristic.value else {
                            self.logger.debug("read but value is nil")
                            continuation.resume(returning: .failure(.init(description: "read but value is nil")))
                            return
                        }

                        self.logger.debug("received: \(HexEncoding.upper.encode(data: value))")
                        self.environment.register = .value(value)
                        self.readHandler?(value)
                        continuation.resume(returning: .success(value))
                    })
                    .store(in: &cancellables)
                peripheral.readValue(for: characteristicEntry.characteristic)
            }
        }
    }
    
    
    open func assertValue(_ cmd: AssertValue) async -> Result<Void, CommandExecutionFailure> {
        logger.trace()
        
        guard let register = environment.register else {
            return .failure(.init(description: "no value in register"))
        }
        
        switch register {
        case .value(let data):
            guard cmd.value == data else {
                return .failure(.init(description: "value mismatch. Want \(HexEncoding.upper.encode(data: cmd.value)), but got \(HexEncoding.upper.encode(data: data))"))
            }
            return .success(())
        }
    }
    
    
    open func sleep(_ cmd: Sleep) async -> Result<Void, CommandExecutionFailure> {
        logger.trace()
        
        do {
            try await Task.sleep(nanoseconds: UInt64(cmd.duration * 1_000_000_000))
        } catch (let e) {
            return .failure(.init(wrapping: e))
        }
        
        return .success(())
    }
    
    
    open func waitForNotification(_ cmd: WaitForNotification) async -> Result<Void, CommandExecutionFailure> {
        logger.trace()
        
        switch await assertCharacteristic(.init(characteristicUUID: cmd.characteristicUUID, serviceUUID: cmd.serviceUUID)) {
        case .failure(let error):
            return .failure(error)
        case .success((_, let characteristicEntry)):
            return await withCheckedContinuation { continuation in
                var cancellables = Set<AnyCancellable>()
                peripheral.didUpdateValueForCharacteristic
                    .sink(receiveValue: { [weak self] resp in
                        defer { cancellables.removeAll() }
                        guard let self else { return }
                        
                        if let error = resp.error {
                            self.logger.error("failed to update value: \(error)")
                            continuation.resume(returning: .failure(.init(wrapping: error)))
                            return
                        }
                        
                        guard let value = resp.characteristic.value else {
                            self.logger.debug("read but value is nil")
                            continuation.resume(returning: .failure(.init(description: "read but value is nil")))
                            return
                        }

                        self.logger.debug("received: \(HexEncoding.upper.encode(data: value))")
                        self.environment.register = .value(value)
                        continuation.resume(returning: .success(()))
                    })
                    .store(in: &cancellables)
                peripheral.setNotifyValue(true, for: characteristicEntry.characteristic)
            }
        }
    }
}
