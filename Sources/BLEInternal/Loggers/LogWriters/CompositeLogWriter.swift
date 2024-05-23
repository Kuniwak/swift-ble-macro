/// A logger that logs to multiple loggers at once.
public struct CompositeLogWriter: LogWriterProtocol {
    private let writers: [any LogWriterProtocol]
    
    
    public init(composing writers: [any LogWriterProtocol]) {
        self.writers = writers
    }
    
    
    public mutating func log(_ severity: LogSeverity, _ message: String) {
        for var writer in writers {
            writer.log(severity, message)
        }
    }
}
