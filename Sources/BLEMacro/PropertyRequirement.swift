import Foundation


public struct PropertyRequirement: RawRepresentable, Equatable, Codable {
    public typealias RawValue = String
    
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public static let mandatory = PropertyRequirement(rawValue: "MANDATORY")
    public static let optional = PropertyRequirement(rawValue: "OPTIONAL")
    public static let excluded = PropertyRequirement(rawValue: "EXCLUDED")
    
    
    public static func parse(xml: XMLElement) -> Result<PropertyRequirement, MacroXMLError> {
        guard let rawValue = xml.attribute(forName: "requirement")?.stringValue else {
            return .failure(.missingAttribute(element: xml.name, attribute: "requirement"))
        }
        
        switch rawValue {
        case mandatory.rawValue:
            return .success(mandatory)
        case optional.rawValue:
            return .success(optional)
        case excluded.rawValue:
            return .success(excluded)
        default:
            return .failure(.notSupportedRequirement(value: rawValue))
        }
    }
}
