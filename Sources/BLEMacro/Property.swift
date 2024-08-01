import Fuzi


public struct Property: Equatable, Codable, Sendable {
    public let name: PropertyName
    public let requirement: PropertyRequirement?

    
    public init(
        name: PropertyName,
        requirement: PropertyRequirement?
    ) {
        self.name = name
        self.requirement = requirement
    }
    
    
    public static let name = "property"
    public static let nameAttribute = "name"
    public static let requirementAttribute = "requirement"


    public static func parse(xml: Fuzi.XMLElement) -> Result<Property, MacroXMLError> {
        guard xml.tag == name else {
            return .failure(.unexpectedElement(expected: name, actual: xml.tag))
        }
        
        switch (PropertyName.parse(xml: xml), PropertyRequirement.parse(xml: xml)) {
        case (.failure(let error), _):
            return .failure(error)
        case (_, .failure(let error)):
            return .failure(error)
        case (.success(let name), .success(let requirement)):
            return .success(Property(name: name, requirement: requirement))
        }
    }
    
    
    public func xml() -> MacroXMLElement {
        var attributes = [MacroXMLAttribute]()
        
        attributes.append(name.xmlAttribute())
        
        if let requirement = requirement {
            attributes.append(requirement.xmlAttribute())
        }
        
        return MacroXMLElement(
            tag: Property.name,
            attributes: attributes,
            children: []
        )
    }
}


extension Property: CustomStringConvertible {
    public var description: String {
        return "(name: \(name), requirement: \(requirement?.debugDescription ?? "nil"))"
    }
}


extension Property: CustomDebugStringConvertible {
    public var debugDescription: String { description }
}
