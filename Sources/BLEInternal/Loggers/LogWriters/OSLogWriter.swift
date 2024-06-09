import os
import Foundation


/// iOS 12.x compatible log writer for Apple's OSLog
public class OSLogWriter: LogWriterProtocol {
    private let osLog: OSLog
    
    
    public init(_ osLog: OSLog) {
        self.osLog = osLog
    }
    
    
    public static func logType(_ severity: LogSeverity) -> OSLogType {
        switch severity {
        case .debug:
            return .debug
        case .info:
            return .info
        case .notice:
            return .default
        case .error:
            return .error
        case .fault:
            return .fault
        }
    }
    
    
    public func log(_ severity: LogSeverity, _ message: String) {
        let chunks = OSLogWriter.split("[\(severity.description)] \(message)", byByteCount: 1024)
        for chunk in chunks {
            os_log("%@", log: osLog, type: OSLogWriter.logType(severity), chunk)
        }
    }
    
    
    private static func split(_ s: String, byByteCount byteCount: Int) -> [String] {
        var result: [String] = []
        var start = s.startIndex
        while start < s.endIndex {
            let end = s.index(start, offsetBy: byteCount, limitedBy: s.endIndex) ?? s.endIndex
            result.append(String(s[start..<end]))
            start = end
        }
        return result
    }
}
