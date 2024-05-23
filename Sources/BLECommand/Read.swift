import CoreBluetooth


public struct Read: Equatable, Codable, CommandPayloadProtocol {
    public let serviceUUID: CBUUID
    public let characteristicUUID: CBUUID
    public var name: StaticString { "read" }
    public var parameters: [(name: StaticString, value: String)] {
        [
            ("service", serviceUUID.uuidString),
            ("characteristic", characteristicUUID.uuidString),
        ]
    }
    
    
    public init(
        serviceUUID: CBUUID,
        characteristicUUID: CBUUID
    ) {
        self.serviceUUID = serviceUUID
        self.characteristicUUID = characteristicUUID
    }
    
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.serviceUUID = CBUUID(string: try container.decode(String.self, forKey: .serviceUUID))
        self.characteristicUUID = CBUUID(string: try container.decode(String.self, forKey: .characteristicUUID))
    }
    
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(serviceUUID.uuidString, forKey: .serviceUUID)
        try container.encode(characteristicUUID.uuidString, forKey: .characteristicUUID)
    }
    
    
    public enum CodingKeys: String, CodingKey {
        case serviceUUID
        case characteristicUUID
    }
}
