import Fuzi


public struct WritingType: RawRepresentable, Hashable, Codable, Sendable {
    public typealias RawValue = String
    public let rawValue: String
    

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    

    public static let writeRequest = WritingType(rawValue: "WRITE_REQUEST")
    public static let writeCommand = WritingType(rawValue: "WRITE_COMMAND")
    
    public static let attribute = "type"
    
    
    public static func parse(xml: Fuzi.XMLElement) -> Result<WritingType, MacroXMLError> {
        guard let typeString = xml.attr(attribute) else {
            return .failure(.missingAttribute(element: xml.tag, attribute: attribute))
        }
        
        switch typeString {
        case writeRequest.rawValue:
            return .success(writeRequest)
        case writeCommand.rawValue:
            return .success(writeCommand)
        default:
            return .failure(.notSupportedType(element: xml.tag, type: typeString))
        }
    }
    
    
    public func xmlAttribute() -> MacroXMLAttribute {
        MacroXMLAttribute(name: WritingType.attribute, value: rawValue)
    }
}


extension WritingType: CustomStringConvertible {
    public var description: String { rawValue }
}


extension WritingType: CaseIterable {
    public static var allCases: [WritingType] {
        [.writeRequest, .writeCommand]
    }
}
