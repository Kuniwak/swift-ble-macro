import Foundation

internal enum URLExtensions {
    internal static func append(toURL url: UnsafeMutablePointer<URL>, _ components: String..., isDirectory: Bool) {
        if #available(macOS 13.0, *) {
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
}
