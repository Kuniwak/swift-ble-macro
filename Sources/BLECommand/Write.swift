import Foundation
import CoreBluetooth
import BLEInternal


public struct Write: Equatable, Codable, CommandPayloadProtocol {
    public let serviceUUID: CBUUID
    public let characteristicUUID: CBUUID
    public let value: Data
    public let writeType: CBCharacteristicWriteType
    
    public var name: StaticString { "write" }
    public var parameters: [(name: StaticString, value: String)] {
        [
            ("service", serviceUUID.uuidString),
            ("characteristic", characteristicUUID.uuidString),
            ("value", HexEncoding.upper.encode(data: value)),
            ("writeType", writeType.rawValue > 0 ? "withResponse" : "withoutResponse"),
        ]
    }

    
    public init(
        serviceUUID: CBUUID,
        characteristicUUID: CBUUID,
        value: Data,
        writeType: CBCharacteristicWriteType
    ) {
        self.serviceUUID = serviceUUID
        self.characteristicUUID = characteristicUUID
        self.value = value
        self.writeType = writeType
    }
    
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.serviceUUID = CBUUID(string: try container.decode(String.self, forKey: .serviceUUID))
        self.characteristicUUID = CBUUID(string: try container.decode(String.self, forKey: .characteristicUUID))
        self.value = try container.decode(Data.self, forKey: .value)
        self.writeType = CBCharacteristicWriteType(rawValue: try container.decode(Int.self, forKey: .writeType))!
    }
    
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(serviceUUID.uuidString, forKey: .serviceUUID)
        try container.encode(characteristicUUID.uuidString, forKey: .characteristicUUID)
        try container.encode(value, forKey: .value)
        try container.encode(writeType.rawValue, forKey: .writeType)
    }
    
    
    public enum CodingKeys: String, CodingKey {
        case serviceUUID
        case characteristicUUID
        case value
        case writeType
    }
}
