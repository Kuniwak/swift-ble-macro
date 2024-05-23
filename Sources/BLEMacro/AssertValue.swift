import Foundation
import BLEInternal


public struct AssertValue: Equatable {
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


    public static func parse(xml: XMLElement) -> Result<AssertValue, MacroXMLError> {
        guard xml.name == name else {
            return .failure(.unexpectedElement(expected: AssertValue.name, actual: xml.name))
        }

        let description = xml.attribute(forName: descriptionAttribute)?.stringValue

        if let value = xml.attribute(forName: valueAttribute)?.stringValue {
            switch HexEncoding.decode(hexString: value) {
            case .failure(let error):
                return .failure(.malformedValueAttribute(hexEncodingError: error))
                
            case .success(let (data, encoding)):
                return .success(.init(description: description, value: .data(data: data, encoding: encoding)))
            }
        }

        if let value = xml.attribute(forName: valueStringAttribute)?.stringValue {
            return .success(.init(description: description, value: .string(value)))
        }

        return .failure(.missingValueOrValueStringAttribute(name: xml.name))
    }
    
    
    public static func parse(childrenOf xml: XMLElement) -> Result<[AssertValue], MacroXMLError> {
        let children = xml.children ?? []
        
        let assertValueResults = children.compactMap { child -> Result<AssertValue, MacroXMLError>? in
            guard let element = child as? XMLElement else {
                return nil
            }
            
            return AssertValue.parse(xml: element)
        }
        
        return Results.combineAll(assertValueResults)
    }


    public func xml() -> XMLElement {
        let element = XMLElement(name: AssertValue.name)
        if let description = description {
            let attr = XMLNode(kind: .attribute)
            attr.name = AssertValue.descriptionAttribute
            attr.stringValue = description
            element.addAttribute(attr)
        }
        value.addAttribute(toElement: element)
        return element
    }
}
