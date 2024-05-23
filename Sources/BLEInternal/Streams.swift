import Foundation


public func print(toStdout string: String, newLine: Bool = true) {
    try! FileHandle.standardOutput.write(contentsOf: (newLine ? string + "\n" : string).data(using: .utf8)!)
}


public func print(toStderr string: String, newLine: Bool = true) {
    try! FileHandle.standardError.write(contentsOf: (newLine ? string + "\n" : string).data(using: .utf8)!)
}
