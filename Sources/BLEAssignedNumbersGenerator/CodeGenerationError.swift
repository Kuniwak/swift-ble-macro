import Foundation


public enum CodeGenerationError: Error, Equatable {
    case emptyPath(url: URL)
    case couldNotWriteFile(url: URL, error: String)
}
