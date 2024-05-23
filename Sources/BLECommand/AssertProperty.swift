import CoreBluetooth


public struct AssertProperty: Equatable, Codable, CommandPayloadProtocol {
    public let property: CBCharacteristicProperties
    public let requirement: Requirement?
    public let characteristicUUID: CBUUID
    public let serviceUUID: CBUUID
    public var name: StaticString { "assert-property" }
    public var parameters: [(name: StaticString, value: String)] {
        [
            ("property", property.rawValue.description),
            ("requirement", requirement?.rawValue ?? "nil"),
            ("characteristic", characteristicUUID.uuidString),
            ("service", serviceUUID.uuidString),
        ]
    }

    
    public init(property: CBCharacteristicProperties, requirement: Requirement?, characteristicUUID: CBUUID, serviceUUID: CBUUID) {
        self.property = property
        self.requirement = requirement
        self.characteristicUUID = characteristicUUID
        self.serviceUUID = serviceUUID
    }
    
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.property = CBCharacteristicProperties(rawValue: try container.decode(UInt.self, forKey: .property))
        self.requirement = try container.decode(Requirement?.self, forKey: .requirement)
        self.characteristicUUID = CBUUID(string: try container.decode(String.self, forKey: .characteristicUUID))
        self.serviceUUID = CBUUID(string: try container.decode(String.self, forKey: .serviceUUID))
    }
    
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(property.rawValue, forKey: .property)
        try container.encode(requirement, forKey: .requirement)
        try container.encode(characteristicUUID.uuidString, forKey: .characteristicUUID)
        try container.encode(serviceUUID.uuidString, forKey: .serviceUUID)
    }
    
    
    public enum CodingKeys: String, CodingKey {
        case property
        case requirement
        case characteristicUUID
        case serviceUUID
    }
}
