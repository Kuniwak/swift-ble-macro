public protocol LogWriterProtocol {
    func log(_ severity: LogSeverity, _ message: String)
}
