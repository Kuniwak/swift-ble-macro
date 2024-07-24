import Combine
import CoreBluetooth
import CoreBluetoothTestable
import BLEInternal
import BLECommand
import BLETasks
import Logger


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
    private let peripheral: any PeripheralTasksProtocol
    private let logger: any LoggerProtocol
    private let timeout: TimeInterval = 5
    private let readHandler: ((Data) -> Void)?

    
    public init(startsWith environment: Environment, onPeripheral peripheral: any PeripheralTasksProtocol, loggingBy logger: any LoggerProtocol, _ readHandler: ((Data) -> Void)? = nil) {
        self.environment = environment
        self.peripheral = peripheral
        self.logger = logger
        self.readHandler = readHandler
    }
    
    
    public init(onPeripheral peripheral: any PeripheralTasksProtocol, loggingBy logger: any LoggerProtocol, _ readHandler: ((Data) -> Void)? = nil) {
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
            logger.debug("service cache \(cmd.serviceUUID) found")
            return .success(serviceEntry)
        }
        
        logger.debug("service cache \(cmd.serviceUUID) not found. discovering...")
        return await self.waitService(uuid: cmd.serviceUUID, timeout: timeout)
            .map { service in
                let serviceEntry = ServiceEntry(service: service, characteristics: [:])
                self.environment.serviceEntries[cmd.serviceUUID] = serviceEntry
                return serviceEntry
            }
    }
    
    
    public func waitService(uuid: CBUUID, timeout: TimeInterval) async -> Result<any ServiceProtocol, CommandExecutionFailure> {
        let logger = self.logger
        logger.trace()
        
        let result = await Tasks.timeout(duration: timeout) {
            return await peripheral.discoverService(searching: uuid)
        }
        switch result {
        case .failure(let error):
            logger.error("timeout: \(error.description)")
            return .failure(.init(wrapping: error))
        case .success(.failure(let error)):
            logger.error("failed to discover service: \(error.description)")
            return .failure(.init(wrapping: error))
        case .success(.success(let service)):
            logger.debug("service \(uuid) found")
            return .success(service)
        }
    }
    
    
    open func assertCharacteristic(_ cmd: AssertCharacteristic) async -> Result<(serviceEntry: ServiceEntry, characteristicEntry: CharacteristicEntry), CommandExecutionFailure> {
        logger.trace()
        
        switch await assertService(.init(serviceUUID: cmd.serviceUUID)) {
        case .failure(let error):
            return .failure(error)
        case .success(let serviceEntry):
            if let characteristicEntry = serviceEntry.characteristics[cmd.characteristicUUID] {
                logger.debug("characteristic cache \(cmd.characteristicUUID) found")
                return .success((serviceEntry, characteristicEntry))
            }
            
            logger.debug("characteristic cache \(cmd.characteristicUUID) not found. discovering...")
            return await self.waitCharacteristic(for: cmd.characteristicUUID, with: serviceEntry.service, timeout: timeout)
                .map { characteristic in
                    let characteristicEntry = CharacteristicEntry(characteristic: characteristic, descriptors: [:])
                    var newServiceEntry = serviceEntry
                    newServiceEntry.characteristics[cmd.characteristicUUID] = characteristicEntry
                    environment.serviceEntries[cmd.serviceUUID] = newServiceEntry
                    return (newServiceEntry, characteristicEntry)
                }
        }
    }
    
    
    public func waitCharacteristic(for uuid: CBUUID, with service: any ServiceProtocol, timeout: TimeInterval) async -> Result<any CharacteristicProtocol, CommandExecutionFailure> {
        let logger = self.logger
        logger.trace()
        
        let result = await Tasks.timeout(duration: timeout) {
            await peripheral.discoverCharacteristic(searching: uuid, forService: service)
        }
        switch result {
        case .failure(let error):
            logger.error("timeout: \(error.description)")
            return .failure(.init(wrapping: error))
        case .success(.failure(let error)):
            logger.error("failed to discover characteristics: \(error.description)")
            return .failure(.init(wrapping: error))
        case .success(.success(let characteristic)):
            logger.debug("characteristic \(uuid) found")
            return .success(characteristic)
        }
    }
    
    
    open func assertDescriptor(_ cmd: AssertDescriptor) async -> Result<(serviceEntry: ServiceEntry, characteristicEntry: CharacteristicEntry, descriptor: any DescriptorProtocol), CommandExecutionFailure> {
        logger.trace()
        
        switch await assertCharacteristic(.init(characteristicUUID: cmd.characteristicUUID, serviceUUID: cmd.serviceUUID)) {
        case .failure(let error):
            return .failure(error)
        case .success((serviceEntry: let serviceEntry, characteristicEntry: let characteristicEntry)):
            if let descriptor = characteristicEntry.descriptors[cmd.descriptorUUID] {
                logger.debug("Descriptor cache \(cmd.descriptorUUID) found")
                return .success((serviceEntry: serviceEntry, characteristicEntry: characteristicEntry, descriptor: descriptor))
            }
            
            logger.debug("Descriptor cache \(cmd.descriptorUUID) not found. discovering...")
            return await waitDescriptor(for: cmd.descriptorUUID, withCharacteristic: characteristicEntry.characteristic, withService: serviceEntry.service, timeout: timeout)
                .map { descriptor in
                    var newCharacteristicEntry = characteristicEntry
                    newCharacteristicEntry.descriptors[cmd.descriptorUUID] = descriptor
                    var newServiceEntry = serviceEntry
                    newServiceEntry.characteristics[cmd.characteristicUUID] = newCharacteristicEntry
                    environment.serviceEntries[cmd.serviceUUID] = newServiceEntry
                    return (newServiceEntry, newCharacteristicEntry, descriptor)
                }
        }
    }
    
    
    public func waitDescriptor(
        for uuid: CBUUID,
        withCharacteristic characteristic: any CharacteristicProtocol,
        withService service: any ServiceProtocol,
        timeout: TimeInterval
    ) async -> Result<any DescriptorProtocol, CommandExecutionFailure> {
        logger.trace()
        
        let result = await Tasks.timeout(duration: timeout) {
            await peripheral.discoverDescriptor(searching: uuid, forCharacteristic: characteristic)
        }
        switch result {
        case .failure(let error):
            logger.error("timeout: \(error.description)")
            return .failure(.init(wrapping: error))
        case .success(.failure(let error)):
            logger.error("failed to discover descriptor: \(error.description)")
            return .failure(.init(wrapping: error))
        case .success(.success(let descriptor)):
            logger.debug("descriptor \(uuid) found")
            return .success(descriptor)
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
            logger.error("failed to discover characteristic: \(error.description)")
            return .failure(error)
        case .success((_, let characteristicEntry)):
            return await peripheral
                .write(
                    forCharacteristic: characteristicEntry.characteristic,
                    value: cmd.value,
                    writeType: cmd.writeType
                )
                .mapError(CommandExecutionFailure.init(wrapping:))
        }
    }
    
    
    open func writeDescriptor(_ cmd: WriteDescriptor) async -> Result<Void, CommandExecutionFailure> {
        logger.trace()
        
        switch await assertDescriptor(.init(descriptorUUID: cmd.descriptorUUID, characteristicUUID: cmd.characteristicUUID, serviceUUID: cmd.serviceUUID)) {
        case .failure(let error):
            return .failure(error)
        case .success((_, let characteristic, let descriptor)):
            return await peripheral
                .write(
                    forDescriptor: descriptor,
                    onCharacteristic: characteristic.characteristic,
                    value: cmd.value
                )
                .mapError(CommandExecutionFailure.init(wrapping:))
        }
    }
    
    
    open func read(_ cmd: Read) async -> Result<Data, CommandExecutionFailure> {
        logger.trace()
        
        switch await assertCharacteristic(.init(characteristicUUID: cmd.characteristicUUID, serviceUUID: cmd.serviceUUID)) {
        case .failure(let error):
            return .failure(error)
        case .success((_, let characteristicEntry)):
            switch await peripheral.read(fromCharacteristic: characteristicEntry.characteristic) {
            case .failure(let error):
                logger.debug("Failed to read: \(error)")
                return .failure(.init(wrapping: error))
            case .success(let value):
                logger.debug("Received: \(HexEncoding.upper.encode(data: value))")
                readHandler?(value)
                environment.register = .value(value)
                return .success(value)
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
            return await peripheral
                .waitForNotification(onCharacteristic: characteristicEntry.characteristic)
                .mapError(CommandExecutionFailure.init(wrapping:))
        }
    }
}
