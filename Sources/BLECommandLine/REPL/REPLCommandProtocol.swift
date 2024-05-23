public protocol REPLCommandProtocol {
    var name: String { get }
    var aliases: [String] { get }
    var abstract: String { get }
    var usage: String { get }
    func run<Args>(args: Args) async -> Result<Void, REPLError> where Args: RandomAccessCollection, Args.Element == String, Args.Index == Int
}
