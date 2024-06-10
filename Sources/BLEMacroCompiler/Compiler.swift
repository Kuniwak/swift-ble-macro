import Foundation
import Combine
import CoreBluetooth
import BLEInternal
import BLEMacro
import BLECommand
import BLEAssignedNumbers
import Logger


open class Compiler {
    private let logger: LoggerProtocol
    
    
    public init(loggingBy logger: LoggerProtocol) {
        self.logger = logger
    }
    
    
    open func compile(macro: Macro) -> Result<[Command], CompilationError> {
        var commands = [Command]()
        
        for assertService in macro.assertServices {
            switch compile(assertService: assertService) {
            case .failure(let error):
                return .failure(error)
            case .success(let cmds):
                commands.append(contentsOf: cmds)
            }
        }
        
        for operation in macro.operations {
            switch compile(operation: operation) {
            case .failure(let error):
                return .failure(error)
            case .success(let cmds):
                commands.append(contentsOf: cmds)
            }
        }
        
        return .success(commands)
    }
    
    
    open func compile(assertService: BLEMacro.AssertService) -> Result<[Command], CompilationError> {
        var commands: [Command] = [.assertService(BLECommand.AssertService(serviceUUID: CBUUID(nsuuid: assertService.uuid)))]
        
        for assertCharacteristic in assertService.assertCharacteristics {
            switch compile(assertCharacteristic: assertCharacteristic, serviceUUID: assertService.uuid) {
            case .failure(let error):
                return .failure(error)
            case .success(let cmds):
                commands.append(contentsOf: cmds)
            }
        }
        
        return .success(commands)
    }
    
    
    open func compile(assertCharacteristic: BLEMacro.AssertCharacteristic, serviceUUID: UUID) -> Result<[Command], CompilationError> {
        var commands: [Command] = [
            .assertCharacteristic(BLECommand.AssertCharacteristic(
                characteristicUUID: CBUUID(nsuuid: assertCharacteristic.uuid),
                serviceUUID: CBUUID(nsuuid: serviceUUID)
            ))
      ]
        
        for assertDescriptor in assertCharacteristic.assertDescriptors {
            commands.append(compile(assertDescriptor: assertDescriptor, characteristicUUID: assertCharacteristic.uuid, serviceUUID: serviceUUID))
        }
        
        if let assertCCCD = assertCharacteristic.assertCCCD {
            commands.append(compile(assertCCCD: assertCCCD, characteristicUUID: assertCharacteristic.uuid, serviceUUID: serviceUUID))
        }
        
        for property in assertCharacteristic.properties {
            switch compile(property: property, characteristicUUID: assertCharacteristic.uuid, serviceUUID: serviceUUID) {
            case .failure(let error):
                return .failure(error)
            case .success(let command):
                commands.append(command)
            }
        }
        
        return .success(commands)
    }
                          
                          
    open func compile(assertDescriptor: BLEMacro.AssertDescriptor, characteristicUUID: UUID, serviceUUID: UUID) -> Command {
        return .assertDescriptor(BLECommand.AssertDescriptor(
            descriptorUUID: CBUUID(nsuuid: assertDescriptor.uuid),
            characteristicUUID: CBUUID(nsuuid: characteristicUUID),
            serviceUUID: CBUUID(nsuuid: serviceUUID)
        ))
    }
    
    
    open func compile(assertCCCD: BLEMacro.AssertCCCD, characteristicUUID: UUID, serviceUUID: UUID) -> Command {
        return .assertDescriptor(BLECommand.AssertDescriptor(
            descriptorUUID: CBUUID(nsuuid: AssignedNumbers.Descriptors.clientCharacteristicConfiguration.uuid()),
            characteristicUUID: CBUUID(nsuuid: characteristicUUID),
            serviceUUID: CBUUID(nsuuid: serviceUUID)
        ))
    }
    
    
    open func compile(property: BLEMacro.Property, characteristicUUID: UUID, serviceUUID: UUID) -> Result<Command, CompilationError> {
        let requirement: Requirement?
        switch property.requirement?.requirement {
        case .some(.failure(let error)):
            return .failure(error)
        case .none:
            requirement = nil
        case .some(.success(let req)):
            requirement = req
        }
        
        return property.name.cbCharacteristicProperties.map { cbCharacteristicProperties in
            return .assertProperty(AssertProperty(
                property: cbCharacteristicProperties,
                requirement: requirement,
                characteristicUUID: CBUUID(nsuuid: characteristicUUID),
                serviceUUID: CBUUID(nsuuid: serviceUUID)
            ))
        }
    }
    
    
    open func compile(operation: BLEMacro.Operation) -> Result<[Command], CompilationError> {
        switch operation {
        case .notSupported(element: let element):
            return .failure(CompilationError(description: "Operation \(element) is not supported"))
        case .write(let write):
            return compile(write: write)
        case .writeDescriptor(let writeDescriptor):
            return compile(writeDescriptor: writeDescriptor)
        case .read(let read):
            return compile(read: read)
        case .sleep(let sleep):
            return compile(sleep: sleep)
        case .waitForNotification(let waitForNotification):
            return compile(waitForNotification: waitForNotification)
        }
    }
    
    
    open func compile(write: BLEMacro.Write) -> Result<[Command], CompilationError> {
        return write.type.cbCharacteristicWriteType.map { characteristicWriteType in
            return [.write(BLECommand.Write(
                serviceUUID: CBUUID(nsuuid: write.serviceUUID),
                characteristicUUID: CBUUID(nsuuid: write.characteristicUUID),
                value: write.value.data,
                writeType: characteristicWriteType
            ))]
        }
    }
    
    
    open func compile(writeDescriptor: BLEMacro.WriteDescriptor) -> Result<[Command], CompilationError> {
        return .success([.writeDescriptor(BLECommand.WriteDescriptor(
            serviceUUID: CBUUID(nsuuid: writeDescriptor.serviceUUID),
            characteristicUUID: CBUUID(nsuuid: writeDescriptor.characteristicUUID),
            descriptorUUID: CBUUID(nsuuid: writeDescriptor.uuid),
            value: writeDescriptor.value.data
        ))])
    }
    
    
    open func compile(read: BLEMacro.Read) -> Result<[Command], CompilationError> {
        var commands: [Command] = [
            .read(BLECommand.Read(
                serviceUUID: CBUUID(nsuuid: read.serviceUUID),
                characteristicUUID: CBUUID(nsuuid: read.characteristicUUID)
            ))
        ]
        
        if let assertValue = read.assertValue {
            commands.append(.assertValue(BLECommand.AssertValue(value: assertValue.value.data)))
        }
        return .success(commands)
    }
    
    
    open func compile(sleep: BLEMacro.Sleep) -> Result<[Command], CompilationError> {
        return .success([.sleep(BLECommand.Sleep(duration: TimeInterval(sleep.timeout / 1000)))])
    }
    
    
    open func compile(waitForNotification: BLEMacro.WaitForNotification) -> Result<[Command], CompilationError> {
        return .success([.waitForNotification(BLECommand.WaitForNotification(
            serviceUUID: CBUUID(nsuuid: waitForNotification.serviceUUID),
            characteristicUUID: CBUUID(nsuuid: waitForNotification.characteristicUUID)
        ))])
    }
}


extension BLEMacro.PropertyName {
    var cbCharacteristicProperties: Result<CBCharacteristicProperties, CompilationError> {
        switch self {
        case .broadcast:
            return .success(.broadcast)
        case .extendedProperties:
            return .success(.extendedProperties)
        case .indicate:
            return .success(.indicate)
        case .notify:
            return .success(.notify)
        case .read:
            return .success(.read)
        case .signedWrite:
            return .success(.authenticatedSignedWrites)
        case .write:
            return .success(.write)
        case .writeWithoutResponse:
            return .success(.writeWithoutResponse)
        default:
            return .failure(CompilationError(description: "Property \(self) is not supported"))
        }
    }
}


extension BLEMacro.PropertyRequirement {
    var requirement: Result<Requirement, CompilationError> {
        switch self {
        case .mandatory:
            return .success(.mandatory)
        case .optional:
            return .success(.optional)
        case .excluded:
            return .success(.excluded)
        default:
            return .failure(CompilationError(description: "PropertyRequirement \(self) is not supported"))
        }
    }
}


extension BLEMacro.WritingType {
    var cbCharacteristicWriteType: Result<CBCharacteristicWriteType, CompilationError> {
        switch self {
        case .writeRequest:
            return .success(.withResponse)
        case .writeCommand:
            return .success(.withoutResponse)
        default:
            return .failure(.init(description: "WritingType \(self.description) is not supported"))
        }
    }
}
