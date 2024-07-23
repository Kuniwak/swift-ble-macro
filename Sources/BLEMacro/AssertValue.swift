import Fuzi
import BLEInternal


public struct AssertValue: Equatable, Codable, Sendable {
    public let description: String?
    public let value: Value


    public init(
        description: String?,
        value: Value
    ) {
        self.description = description
        self.value = value
    }


    public static let name = "assert-value"
    public static let descriptionAttribute = "description"
    public static let valueAttribute = "value"
    public static let valueStringAttribute = "value-string"


    public static func parse(xml: Fuzi.XMLElement) -> Result<AssertValue, MacroXMLError> {
        guard xml.tag == name else {
            return .failure(.unexpectedElement(expected: AssertValue.name, actual: xml.tag))
        }

        let description = xml.attr(descriptionAttribute)

        if let value = xml.attr(valueAttribute) {
            switch HexEncoding.decode(hexString: value) {
            case .failure(let error):
                return .failure(.malformedValueAttribute(hexEncodingError: error))
                
            case .success(let (data, encoding)):
                return .success(.init(description: description, value: .data(data: data, encoding: encoding)))
            }
        }

        if let value = xml.attr(valueStringAttribute) {
            return .success(.init(description: description, value: .string(value)))
        }

        return .failure(.missingValueOrValueStringAttribute(name: xml.tag))
    }
    
    
    public static func parse(childrenOf xml: Fuzi.XMLElement) -> Result<[AssertValue], MacroXMLError> {
        let assertValueResults = xml.children.compactMap { child -> Result<AssertValue, MacroXMLError>? in
            return AssertValue.parse(xml: child)
        }
        
        return Results.combineAll(assertValueResults)
    }


    public func xml() -> XMLElement {
        var attributes = [String: String]()
        
        if let description = description {
            attributes[AssertValue.descriptionAttribute] = description
        }
        
        value.addAttribute(to: &attributes)
        
        return XMLElement(tag: AssertValue.name, attributes: attributes, children: [])
    }
}
