public protocol CommandPayloadProtocol {
    var name: StaticString { get }
    var parameters: [(name: StaticString, value: String)] { get }
}


extension CommandPayloadProtocol {
    public var desscription: String {
        let params = parameters.map { "\t\($0.name)=\($0.value)"}.joined(separator: "\n")
        return "\(name)\n\(params)"
    }
}
