import struct Foundation.Data
import Fuzi
import BLEInternal


public enum Value: Equatable, Codable, Sendable {
    typealias RawValue = String

    case data(data: Data, encoding: HexEncoding)
    case string(String)


    public static let valueAttributeName = "value"
    public static let valueStringAttributeName = "value-string"


    public func addAttribute(to attributes: inout [String: String]) {
        switch self {
        case .data(let data, let encoding):
            attributes[Value.valueAttributeName] = encoding.encode(data: data)
        case .string(let string):
            attributes[Value.valueStringAttributeName] = string
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
            case .success(let (data, encoding)):
                return .success(.data(data: data, encoding: encoding))
            }
        } else if let valueString = xml.attr(valueStringAttributeName) {
            return .success(.string(valueString))
        } else {
            return .failure(.missingValueOrValueStringAttribute(name: xml.tag))
        }
    }
    
    
    public var data: Data {
        switch self {
        case .data(let data, _):
            return data
        case .string(let string):
            return Data(string.utf8)
        }
    }
}
