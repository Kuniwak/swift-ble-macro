public struct UUIDError: Error, Equatable, CustomStringConvertible {
    public let description: String
    
    public init(_ description: String) {
        self.description = description
    }
    
    public init(wrapping error: any Error) {
        self.description = "\(error)"
    }
    
    public static func malformedHexString(_ s: String) -> UUIDError {
        return UUIDError("malformed hex string: \(s)")
    }
}
