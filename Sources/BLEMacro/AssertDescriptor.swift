import struct Foundation.UUID
import Fuzi


public struct AssertDescriptor: Equatable, Codable, Sendable {
    public let description: String?
    public let uuid: UUID

    public init(
        description: String?,
        uuid: UUID
    ) {
        self.description = description
        self.uuid = uuid
    }


    public static let name = "assert-descriptor"
    public static let descriptionAttribute = "description"
    public static let uuidAttribute = "uuid"
    public static let instanceIDAttribute = "instance-id"


    public static func parse(xml: Fuzi.XMLElement) -> Result<AssertDescriptor, MacroXMLError> {
        guard xml.tag == name else {
            return .failure(.unexpectedElement(expected: AssertDescriptor.name, actual: xml.tag))
        }

        let description = xml.attr(descriptionAttribute)

        guard let uuidString = xml.attr(uuidAttribute) else {
            return .failure(.missingAttribute(element: xml.tag, attribute: uuidAttribute))
        }
        guard let uuid = UUID(uuidString: uuidString) else {
            return .failure(.malformedUUIDAttribute(element: uuidString, attribute: uuidAttribute, uuidString: uuidString))
        }

        return .success(
            AssertDescriptor(
                description: description,
                uuid: uuid
            )
        )
    }
    
    
    public func xml() -> MacroXMLElement {
        var attributes = [MacroXMLAttribute]()
        
        if let description = description {
            attributes.append(MacroXMLAttribute(name: AssertDescriptor.descriptionAttribute, value: description))
        }
        
        attributes.append(MacroXMLAttribute(name: AssertDescriptor.uuidAttribute, value: uuid.uuidString))
        
        return MacroXMLElement(
            tag: AssertDescriptor.name,
            attributes: attributes,
            children: []
        )
    }
}


extension AssertDescriptor: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "(description: \(description ?? "nil"), uuid: \(uuid.uuidString))"
    }
}
