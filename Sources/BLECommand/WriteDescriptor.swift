import Foundation
import CoreBluetooth
import BLEInternal


public struct WriteDescriptor: Equatable, Codable, CommandPayloadProtocol {
    public let serviceUUID: CBUUID
    public let characteristicUUID: CBUUID
    public let descriptorUUID: CBUUID
    public let value: Data
    
    public var name: StaticString { "write-descriptor" }
    public var parameters: [(name: StaticString, value: String)] {
        [
            ("service", serviceUUID.uuidString),
            ("characteristic", characteristicUUID.uuidString),
            ("descriptor", descriptorUUID.uuidString),
            ("value", HexEncoding.upper.encode(data: value)),
        ]
    }

    
    public init(
        serviceUUID: CBUUID,
        characteristicUUID: CBUUID,
        descriptorUUID: CBUUID,
        value: Data
    ) {
        self.serviceUUID = serviceUUID
        self.characteristicUUID = characteristicUUID
        self.descriptorUUID = descriptorUUID
        self.value = value
    }
    
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.serviceUUID = CBUUID(string: try container.decode(String.self, forKey: .serviceUUID))
        self.characteristicUUID = CBUUID(string: try container.decode(String.self, forKey: .characteristicUUID))
        self.descriptorUUID = CBUUID(string: try container.decode(String.self, forKey: .descriptorUUID))
        self.value = try container.decode(Data.self, forKey: .value)
    }
    
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(serviceUUID.uuidString, forKey: .serviceUUID)
        try container.encode(characteristicUUID.uuidString, forKey: .characteristicUUID)
        try container.encode(descriptorUUID.uuidString, forKey: .descriptorUUID)
        try container.encode(value, forKey: .value)
    }
    
    
    public enum CodingKeys: String, CodingKey {
        case serviceUUID
        case characteristicUUID
        case descriptorUUID
        case value
    }
}
