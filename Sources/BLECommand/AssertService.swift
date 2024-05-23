import CoreBluetooth


public struct AssertService: Equatable, Codable, CommandPayloadProtocol {
    public let serviceUUID: CBUUID
    public var name: StaticString { "assert-service" }
    public var parameters: [(name: StaticString, value: String)] {
        [("service", serviceUUID.uuidString)]
    }

    public init(serviceUUID: CBUUID) {
        self.serviceUUID = serviceUUID
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.serviceUUID = CBUUID(string: try container.decode(String.self, forKey: .serviceUUID))
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(serviceUUID.uuidString, forKey: .serviceUUID)
    }
    
    public enum CodingKeys: String, CodingKey {
        case serviceUUID
    }
}
