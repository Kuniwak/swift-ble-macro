public protocol LoggerProtocol {
    mutating func debug(_ message: String)
    mutating func info(_ message: String)
    mutating func notice(_ message: String)
    mutating func error(_ message: String)
    mutating func fault(_ message: String)
}


extension LoggerProtocol {
    public mutating func trace(_ s: String = #function) {
        debug(s)
    }
}


public struct Logger: LoggerProtocol {
    private let severity: LogSeverity
    private var writer: any LogWriterProtocol
    
    public init(severity: LogSeverity, writer: any LogWriterProtocol) {
        self.severity = severity
        self.writer = writer
    }
    
    public mutating func debug(_ message: String) {
        guard severity <= .debug else { return }
        writer.log(.debug, message)
    }
    
    public mutating func info(_ message: String) {
        guard severity <= .info else { return }
        writer.log(.info, message)
    }
    
    public mutating func notice(_ message: String) {
        guard severity <= .notice else { return }
        writer.log(.notice, message)
    }
    
    public mutating func error(_ message: String) {
        guard severity <= .error else { return }
        writer.log(.error, message)
    }
    
    public mutating func fault(_ message: String) {
        guard severity <= .fault else { return }
        writer.log(.fault, message)
    }
}
