public protocol LogWriterProtocol {
    mutating func log(_ severity: LogSeverity, _ message: String)
}
