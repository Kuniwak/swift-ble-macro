public struct REPLError: Error, CustomStringConvertible {
    public let description: String
    
    public init(_ description: String) {
        self.description = description
    }
    
    
    public init (wrapping error: any Error) {
        self.description = "\(error)"
    }
}
