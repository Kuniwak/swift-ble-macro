import Foundation
import BLEInternal


public enum Value: Equatable {
    typealias RawValue = String

    case data(data: Data, encoding: HexEncoding)
    case string(String)


    public static let valueAttributeName = "value"
    public static let valueStringAttributeName = "value-string"


    public func addAttribute(toElement xml: XMLElement) {
        switch self {
        case .data(let data, let encoding):
            let attr = XMLNode(kind: .attribute)
            attr.name = Value.valueAttributeName
            attr.stringValue = encoding.encode(data: data)
            xml.addAttribute(attr)
        case .string(let string):
            let attr = XMLNode(kind: .attribute)
            attr.name = Value.valueStringAttributeName
            attr.stringValue = string
            xml.addAttribute(attr)
        }
    }


    public static func parse(xml: XMLElement) -> Result<Value, MacroXMLError> {
        if let value = xml.attribute(forName: valueAttributeName)?.stringValue {
            guard xml.attribute(forName: valueStringAttributeName)?.stringValue == nil else {
                return .failure(.bothValueAndValueStringAttributesPresent(element: xml.name))
            }
            switch HexEncoding.decode(hexString: value) {
            case .failure(let error):
                return .failure(.malformedValueAttribute(hexEncodingError: error))
            case .success(let (data, encoding)):
                return .success(.data(data: data, encoding: encoding))
            }
        } else if let valueString = xml.attribute(forName: valueStringAttributeName)?.stringValue {
            return .success(.string(valueString))
        } else {
            return .failure(.missingValueOrValueStringAttribute(name: xml.name))
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
