import CoreBluetooth


public struct AssertCharacteristic: Equatable, Codable, CommandPayloadProtocol {
    public let characteristicUUID: CBUUID
    public let serviceUUID: CBUUID
    public var name: StaticString { "assert-characteristic" }
    public var parameters: [(name: StaticString, value: String)] {
        [("characteristic", characteristicUUID.uuidString), ("service", serviceUUID.uuidString)]
    }

    public init(characteristicUUID: CBUUID, serviceUUID: CBUUID) {
        self.characteristicUUID = characteristicUUID
        self.serviceUUID = serviceUUID
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.characteristicUUID = CBUUID(string: try container.decode(String.self, forKey: .characteristicUUID))
        self.serviceUUID = CBUUID(string: try container.decode(String.self, forKey: .serviceUUID))
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(characteristicUUID.uuidString, forKey: .characteristicUUID)
        try container.encode(serviceUUID.uuidString, forKey: .serviceUUID)
    }
    
    public enum CodingKeys: String, CodingKey {
        case characteristicUUID
        case serviceUUID
    }
}
