import Foundation


public func print(toStdout string: String, newLine: Bool = true) {
    let data = (newLine ? string + "\n" : string).data(using: .utf8)!
    if #available(iOS 13.4, tvOS 13.4, watchOS 6.2, *) {
        try! FileHandle.standardOutput.write(contentsOf: data)
    } else {
        FileHandle.standardOutput.write(data)
    }
}


public func print(toStderr string: String, newLine: Bool = true) {
    let data = (newLine ? string + "\n" : string).data(using: .utf8)!
    if #available(iOS 13.4, tvOS 13.4, watchOS 6.2, *) {
        try! FileHandle.standardError.write(contentsOf: (newLine ? string + "\n" : string).data(using: .utf8)!)
    } else {
        FileHandle.standardError.write(data)
    }
}
