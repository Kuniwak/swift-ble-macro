import Foundation


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


    public static func parse(xml: XMLElement) -> Result<Property, MacroXMLError> {
        guard xml.name == name else {
            return .failure(.unexpectedElement(expected: name, actual: xml.name))
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
        let element = XMLElement(name: Property.name)
        
        let nameAttr = XMLNode(kind: .attribute)
        nameAttr.name = Property.nameAttribute
        nameAttr.stringValue = name.rawValue
        
        if let requirement {
            let requirementAttr = XMLNode(kind: .attribute)
            requirementAttr.name = Property.requirementAttribute
            requirementAttr.stringValue = requirement.rawValue
            element.addAttribute(requirementAttr)
        }
        
        return element
    }
}
