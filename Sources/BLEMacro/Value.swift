import struct Foundation.Data
import Fuzi
import BLEInternal


public enum Value: Equatable, Codable, Sendable {
    typealias RawValue = String

    case data(data: Data)
    case string(String)


    public static let valueAttributeName = "value"
    public static let valueStringAttributeName = "value-string"

    
    public var data: Data {
        switch self {
        case .data(let data):
            return data
        case .string(let string):
            return Data(string.utf8)
        }
    }


    public static func parse(xml: Fuzi.XMLElement) -> Result<Value, MacroXMLError> {
        if let value = xml.attr(valueAttributeName) {
            guard xml.attr(valueStringAttributeName) == nil else {
                return .failure(.bothValueAndValueStringAttributesPresent(element: xml.tag))
            }
            switch HexEncoding.decode(hexString: value) {
            case .failure(let error):
                return .failure(.malformedValueAttribute(hexEncodingError: error))
            case .success(let (data, _)):
                return .success(.data(data: data))
            }
        } else if let valueString = xml.attr(valueStringAttributeName) {
            return .success(.string(valueString))
        } else {
            return .failure(.missingValueOrValueStringAttribute(name: xml.tag))
        }
    }

    
    public func xmlAttribute() -> MacroXMLAttribute {
        switch self {
        case .data(let data):
            return MacroXMLAttribute(name: Value.valueAttributeName, value: HexEncoding.upper.encode(data: data))
        case .string(let string):
            return MacroXMLAttribute(name: Value.valueStringAttributeName, value: string)
        }
    }
}


extension Value: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .data(let data):
            return "(data: \(data.debugDescription))"
        case .string(let string):
            return "(string: \(string))"
        }
    }
}
