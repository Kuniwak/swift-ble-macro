import Fuzi


public struct Property: Equatable {
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
    
    
    public func xml() -> XMLElement {
        var attributes = [String: String]()
        
        attributes[Property.nameAttribute] = name.rawValue
        
        if let requirement = requirement {
            attributes[Property.requirementAttribute] = requirement.rawValue
        }
        
        return XMLElement(
            tag: Property.name,
            attributes: attributes,
            children: []
        )
    }
}
