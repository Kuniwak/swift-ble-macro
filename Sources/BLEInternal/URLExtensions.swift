import Foundation

public enum URLExtensions {
    public static func append(toURL url: UnsafeMutablePointer<URL>, _ components: String..., isDirectory: Bool) {
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            for (idx, component) in components.enumerated() {
                let isLast = idx == components.count - 1
                url.pointee.append(component: component, directoryHint: !isLast || isDirectory ? .isDirectory : .notDirectory)
            }
        } else {
            for (idx, component) in components.enumerated() {
                let isLast = idx == components.count - 1
                url.pointee.appendPathComponent(component, isDirectory: !isLast || isDirectory)
            }
        }
    }
    
    
    public static func path(ofURL url: URL) -> String {
        if #available(iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            return url.path()
        } else {
            return url.path
        }
    }
    
    
    public static func append(path: String, toURL url: UnsafeMutablePointer<URL>, isDirectory: Bool) {
        if #available(iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            url.pointee.append(path: path, directoryHint: isDirectory ? .isDirectory : .notDirectory)
        } else {
            url.pointee.appendPathComponent(path, isDirectory: isDirectory)
        }
    }
    
    
    public static func appending(path: String, toURL url: URL, isDirectory: Bool) -> URL {
        if #available(iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            return url.appending(path: path, directoryHint: isDirectory ? .isDirectory : .notDirectory)
        } else {
            return url.appendingPathComponent(path, isDirectory: isDirectory)
        }
    }
}
