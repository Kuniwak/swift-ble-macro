import Foundation


public class FileLogWriter: LogWriterProtocol {
    private let fileHandle: FileHandle
    private let encoding: String.Encoding
    
    
    public init(writeTo fileHandle: FileHandle, encoding: String.Encoding) {
        self.fileHandle = fileHandle
        self.encoding = encoding
    }
    
    
    public func log(_ severity: LogSeverity, _ message: String) {
        guard let data = "\(severity.description): \(message)\n".data(using: encoding) else {
            return
        }
        try? fileHandle.write(contentsOf: data)
        try? fileHandle.synchronize()
    }
}
