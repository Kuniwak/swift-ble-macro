public struct SpyLogger: LoggerProtocol {
    public private(set) var entries = [CapturedLogEntry]()
    
    
    public init() {}
    
    
    public mutating func trace(_ s: String = #function) {
        debug(s)
    }
    
    public mutating func debug(_ message: String) {
        entries.append(.init(severity: .debug, message: message))
    }
    
    public mutating func info(_ message: String) {
        entries.append(.init(severity: .info, message: message))
    }
    
    public mutating func notice(_ message: String) {
        entries.append(.init(severity: .notice, message: message))
    }
    
    public mutating func error(_ message: String) {
        entries.append(.init(severity: .error, message: message))
    }
    
    public mutating func fault(_ message: String) {
        entries.append(.init(severity: .fault, message: message))
    }
}


public struct CapturedLogEntry: Equatable, Codable {
    public let severity: LogSeverity
    public let message: String
    
    public init(severity: LogSeverity, message: String) {
        self.severity = severity
        self.message = message
    }
}
