import Foundation
import BLEInternal
import CoreBluetooth


public enum Command: Equatable, Codable {
    case assertService(AssertService)
    case assertCharacteristic(AssertCharacteristic)
    case assertDescriptor(AssertDescriptor)
    case assertProperty(AssertProperty)
    case assertValue(AssertValue)
    case write(Write)
    case writeDescriptor(WriteDescriptor)
    case read(Read)
    case sleep(Sleep)
    case waitForNotification(WaitForNotification)
    
    
    public var payload: any CommandPayloadProtocol {
        switch self {
        case .assertService(let assertService):
            return assertService
        case .assertCharacteristic(let assertCharacteristic):
            return assertCharacteristic
        case .assertDescriptor(let assertDescriptor):
            return assertDescriptor
        case .assertProperty(let assertProperty):
            return assertProperty
        case .assertValue(let assertValue):
            return assertValue
        case .write(let write):
            return write
        case .writeDescriptor(let writeDescriptor):
            return writeDescriptor
        case .read(let read):
            return read
        case .sleep(let sleep):
            return sleep
        case .waitForNotification(let waitForNotification):
            return waitForNotification
        }
    }
}



extension Command: CustomStringConvertible {
    public var description: String { payload.desscription }
}
