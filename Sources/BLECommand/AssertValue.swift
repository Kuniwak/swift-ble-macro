import Foundation
import BLEInternal


public struct AssertValue: Equatable, Codable, CommandPayloadProtocol {
    public let value: Data
    public var name: StaticString { "assert-value" }
    public var parameters: [(name: StaticString, value: String)] {
        [("value", HexEncoding.upper.encode(data: value))]
    }
    
    
    public init(value: Data) {
        self.value = value
    }
    
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.value = try container.decode(Data.self, forKey: .value)
    }
    
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
    }
    
    
    public enum CodingKeys: String, CodingKey {
        case value
    }
}
