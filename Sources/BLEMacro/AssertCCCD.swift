import Fuzi


public struct AssertCCCD: Equatable, Codable, Sendable {
    public let description: String?


    public init(description: String? = nil) {
        self.description = description
    }


    public static let name = "assert-cccd"
    public static let descriptionAttribute = "description"


    public static func parse(xml: Fuzi.XMLElement) -> Result<AssertCCCD, MacroXMLError> {
        guard xml.tag == name else {
            return .failure(.unexpectedElement(expected: name, actual: xml.tag))
        }

        let description = xml.attr(descriptionAttribute)

        return .success(AssertCCCD(description: description))
    }
    
    
    public func xml() -> MacroXMLElement {
        var attributes = [MacroXMLAttribute]()
        
        if let description = description {
            attributes.append(MacroXMLAttribute(name: AssertCCCD.descriptionAttribute, value: description))
        }
        
        return MacroXMLElement(
            tag: AssertCCCD.name,
            attributes: attributes,
            children: []
        )
    }
}


extension AssertCCCD: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "(description: \(description ?? "nil"))"
    }
}
