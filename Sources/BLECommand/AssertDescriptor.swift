import CoreBluetooth


public struct AssertDescriptor: Equatable, Codable, CommandPayloadProtocol {
    public let descriptorUUID: CBUUID
    public let characteristicUUID: CBUUID
    public let serviceUUID: CBUUID
    public var name: StaticString { "assert-descriptor" }
    public var parameters: [(name: StaticString, value: String)] {
        [
            ("descriptor", descriptorUUID.uuidString),
            ("characteristic", characteristicUUID.uuidString),
            ("service", serviceUUID.uuidString),
        ]
    }

    public init(descriptorUUID: CBUUID, characteristicUUID: CBUUID, serviceUUID: CBUUID) {
        self.descriptorUUID = descriptorUUID
        self.characteristicUUID = characteristicUUID
        self.serviceUUID = serviceUUID
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.descriptorUUID = CBUUID(string: try container.decode(String.self, forKey: .descriptorUUID))
        self.characteristicUUID = CBUUID(string: try container.decode(String.self, forKey: .characteristicUUID))
        self.serviceUUID = CBUUID(string: try container.decode(String.self, forKey: .serviceUUID))
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(descriptorUUID.uuidString, forKey: .descriptorUUID)
        try container.encode(characteristicUUID.uuidString, forKey: .characteristicUUID)
        try container.encode(serviceUUID.uuidString, forKey: .serviceUUID)
    }
    
    public enum CodingKeys: String, CodingKey {
        case descriptorUUID
        case characteristicUUID
        case serviceUUID
    }
}
