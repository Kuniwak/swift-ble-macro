public struct MacroXMLAttribute: Equatable, Codable, Sendable {
    public let namespace: String?
    public let name: String
    public let value: String
    
    
    public init(namespace: String? = nil, name: String, value: String) {
        self.namespace = namespace
        self.name = name
        self.value = value
    }
}
