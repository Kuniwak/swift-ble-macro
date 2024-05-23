public struct NullLogger: LoggerProtocol {
    public func trace(_ s: String = #function) {
        // Do nothing
    }
    
    public func debug(_ message: String) {
        // Do nothing
    }
    
    public func info(_ message: String) {
        // Do nothing
    }
    
    public func notice(_ message: String) {
        // Do nothing
    }
    
    public func error(_ message: String) {
        // Do nothing
    }
    
    public func fault(_ message: String) {
        // Do nothing
    }
}
