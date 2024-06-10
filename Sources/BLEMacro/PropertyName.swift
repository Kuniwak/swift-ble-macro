import Fuzi


public struct PropertyName: RawRepresentable, Hashable, Codable {
    public typealias RawValue = String
    public let rawValue: String
    

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    

    public static let broadcast = PropertyName(rawValue: "BROADCAST")
    public static let read = PropertyName(rawValue: "READ")
    public static let write = PropertyName(rawValue: "WRITE")
    public static let writeWithoutResponse = PropertyName(rawValue: "WRITE_WITHOUT_RESPONSE")
    public static let notify = PropertyName(rawValue: "NOTIFY")
    public static let indicate = PropertyName(rawValue: "INDICATE")
    public static let signedWrite = PropertyName(rawValue: "SIGNED_WRITE")
    public static let extendedProperties = PropertyName(rawValue: "EXTENDED_PROPERTIES")
    
    public static let attributeName = "name"
    
    
    public static func parse(xml: Fuzi.XMLElement) -> Result<PropertyName, MacroXMLError> {
        guard let rawValue = xml.attr(attributeName) else {
            return .failure(.missingAttribute(element: xml.tag, attribute: attributeName))
        }
        
        switch rawValue {
        case broadcast.rawValue:
            return .success(broadcast)
        case read.rawValue:
            return .success(read)
        case write.rawValue:
            return .success(write)
        case writeWithoutResponse.rawValue:
            return .success(writeWithoutResponse)
        case notify.rawValue:
            return .success(notify)
        case indicate.rawValue:
            return .success(indicate)
        case signedWrite.rawValue:
            return .success(signedWrite)
        case extendedProperties.rawValue:
            return .success(extendedProperties)
        default:
            return .failure(.notSupportedProperty(name: rawValue))
        }
    }
}
