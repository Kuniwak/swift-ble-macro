import Foundation


public struct Sleep: Equatable, Codable, CommandPayloadProtocol {
    public let duration: TimeInterval
    public var name: StaticString { "sleep" }
    public var parameters: [(name: StaticString, value: String)] {
        [("duration", duration.description)]
    }
    
    
    public init(duration: TimeInterval) {
        self.duration = duration
    }
    
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.duration = try container.decode(TimeInterval.self, forKey: .duration)
    }
    
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(duration, forKey: .duration)
    }
    
    
    public enum CodingKeys: String, CodingKey {
        case duration
    }
}
