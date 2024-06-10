import Foundation
import os
import BLEInternal
import Logger


public enum LogDestination: Equatable {
    case console
    case osLog(subsystem: String, category: String)
    case file(url: URL, encoding: String.Encoding)
    
    
    public func buildLogWriter() throws -> any LogWriterProtocol {
        switch self {
        case .console:
            return ConsoleLogWriter.stderr
        case .osLog(subsystem: let subsystem, category: let category):
            return OSLogWriter(OSLog(subsystem: subsystem, category: category))
        case .file(url: let url, encoding: let encoding):
            return FileLogWriter(writeTo: try FileHandle(forWritingTo: url), encoding: encoding)
        }
    }
}


