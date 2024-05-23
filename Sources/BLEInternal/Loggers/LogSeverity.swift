/// Log severity levels.
public enum LogSeverity: RawRepresentable, Codable, CaseIterable {
    public typealias RawValue = String
    
    case debug
    case info
    case notice
    case error
    case fault

    public var rawValue: String {
        switch self {
        case .debug:
            return "debug"
        case .info:
            return "info"
        case .notice:
            return "notice"
        case .error:
            return "error"
        case .fault:
            return "fault"
        }
    }

    public init?(rawValue: String) {
        switch rawValue {
        case "debug":
            self = .debug
        case "info":
            self = .info
        case "notice":
            self = .notice
        case "error":
            self = .error
        case "fault":
            self = .fault
        default:
            return nil
        }
    }
}


extension LogSeverity: CustomStringConvertible {
    public var description: String {
        return rawValue
    }
}


extension LogSeverity: Comparable {
    private var index: UInt8 {
        switch self {
        case .debug:
            return 0
        case .info:
            return 1
        case .notice:
            return 2
        case .error:
            return 3
        case .fault:
            return 4
        }
    }
    
    public static func < (lhs: LogSeverity, rhs: LogSeverity) -> Bool {
        return lhs.index < rhs.index
    }
}
