import Fuzi


public struct PropertyRequirement: RawRepresentable, Equatable, Codable, Sendable {
    public typealias RawValue = String
    
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public static let mandatory = PropertyRequirement(rawValue: "MANDATORY")
    public static let optional = PropertyRequirement(rawValue: "OPTIONAL")
    public static let excluded = PropertyRequirement(rawValue: "EXCLUDED")
    
    public static let attributeName = "requirement"
    
    
    public static func parse(xml: Fuzi.XMLElement) -> Result<PropertyRequirement?, MacroXMLError> {
        guard let rawValue = xml.attr(attributeName) else {
            return .success(nil)
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
    
    
    public func xmlAttribute() -> MacroXMLAttribute {
        MacroXMLAttribute(name: PropertyRequirement.attributeName, value: rawValue)
    }
}


extension PropertyRequirement: CustomStringConvertible {
    public var description: String {
        return rawValue
    }
}


extension PropertyRequirement: CustomDebugStringConvertible {
    public var debugDescription: String {
        return rawValue
    }
}


extension PropertyRequirement: CaseIterable {
    public static var allCases: [PropertyRequirement] {
        [.mandatory, .optional, .excluded]
    }
}
