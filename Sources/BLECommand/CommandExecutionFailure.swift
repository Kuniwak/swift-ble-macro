public struct CommandExecutionFailure: Equatable, Error, CustomStringConvertible {
    public let description: String
    
    public init(description: String) {
        self.description = description
    }
    
    public init(wrapping error: any Error) {
        self.init(description: "[\(type(of: error))] \(error)")
    }
    
    public init(wrapping error: (any Error)?) {
        if let error {
            self.init(wrapping: error)
        } else {
            self.init(description: "[\(type(of: error))] nil")
        }
    }
}
