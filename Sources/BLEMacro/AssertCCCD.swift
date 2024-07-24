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
    
    
    public func xml() -> XMLElement {
        var attributes = [String: String]()
        
        if let description = description {
            attributes[AssertCCCD.descriptionAttribute] = description
        }
        
        return XMLElement(
            tag: AssertCCCD.name,
            attributes: attributes,
            children: []
        )
    }
}
