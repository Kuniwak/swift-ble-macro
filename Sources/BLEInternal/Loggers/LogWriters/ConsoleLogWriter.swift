import Foundation


public enum ConsoleLogWriter {
    public static private(set) var stderr = FileLogWriter(writeTo: FileHandle.standardError, encoding: .utf8)
}
