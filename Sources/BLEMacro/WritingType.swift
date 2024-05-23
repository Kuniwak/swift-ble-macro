import Foundation


public struct WritingType: RawRepresentable, Equatable {
    public typealias RawValue = String
    public let rawValue: String
    

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    

    public static let writeRequest = WritingType(rawValue: "WRITE_REQUEST")
    public static let writeCommand = WritingType(rawValue: "WRITE_COMMAND")
    
    public static let attribute = "type"
    
    
    public static func parse(xml: XMLElement) -> Result<WritingType, MacroXMLError> {
        guard let typeString = xml.attribute(forName: attribute)?.stringValue else {
            return .failure(.missingAttribute(element: xml.name, attribute: attribute))
        }
        
        switch typeString {
        case writeRequest.rawValue:
            return .success(writeRequest)
        case writeCommand.rawValue:
            return .success(writeCommand)
        default:
            return .failure(.notSupportedType(element: xml.name, type: typeString))
        }
    }
}


extension WritingType: CustomStringConvertible {
    public var description: String { rawValue }
}
