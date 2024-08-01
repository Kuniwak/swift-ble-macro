public struct MacroXMLElement: Equatable, Codable, Sendable {
    public let namespace: String?
    public var tag: String
    public var attributes: [MacroXMLAttribute]
    public var children: [MacroXMLElement]
    
    public init(namespace: String? = nil, tag: String, attributes: [MacroXMLAttribute], children: [MacroXMLElement]) {
        self.namespace = namespace
        self.tag = tag
        self.attributes = attributes
        self.children = children
    }
}
