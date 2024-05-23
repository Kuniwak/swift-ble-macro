import Foundation


public enum Tasks {
    public static func race2<T>(_ operation1: @escaping @Sendable () async -> T, _ operation2: @escaping @Sendable () async -> T) async -> T {
        return await withTaskGroup(of: T.self) { group in
            defer { group.cancelAll() }
            group.addTask { await operation1() }
            group.addTask { await operation2() }
            return await group.next()!
        }
    }
    
    
    public static func timeout<T>(duration: TimeInterval, _ operation: @escaping @Sendable () async -> T) async -> Result<T, TimeoutError> {
        await race2({ .success(await operation()) }, {
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            return .failure(TimeoutError())
        })
    }
}



public struct TimeoutError: Error, CustomStringConvertible {
    public var description: String { "Timeout exceeded" }
}
