public protocol LoggerProtocol {
    func debug(_ message: String)
    func info(_ message: String)
    func notice(_ message: String)
    func error(_ message: String)
    func fault(_ message: String)
}


extension LoggerProtocol {
    public func trace(_ s: String = #function) {
        debug(s)
    }
}


public class Logger: LoggerProtocol {
    private let severity: LogSeverity
    private let writer: any LogWriterProtocol
    
    public init(severity: LogSeverity, writer: any LogWriterProtocol) {
        self.severity = severity
        self.writer = writer
    }
    
    public func debug(_ message: String) {
        guard severity <= .debug else { return }
        writer.log(.debug, message)
    }
    
    public func info(_ message: String) {
        guard severity <= .info else { return }
        writer.log(.info, message)
    }
    
    public func notice(_ message: String) {
        guard severity <= .notice else { return }
        writer.log(.notice, message)
    }
    
    public func error(_ message: String) {
        guard severity <= .error else { return }
        writer.log(.error, message)
    }
    
    public func fault(_ message: String) {
        guard severity <= .fault else { return }
        writer.log(.fault, message)
    }
}
