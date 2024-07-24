import struct Foundation.UUID
import Fuzi


public struct Read: Equatable, Codable, Sendable {
    public let description: String?
    public let serviceUUID: UUID
    public let characteristicUUID: UUID
    public let assertValue: AssertValue?
    
    
    public init(
        description: String?,
        serviceUUID: UUID,
        characteristicUUID: UUID,
        assertValue: AssertValue?
    ) {
        self.description = description
        self.serviceUUID = serviceUUID
        self.characteristicUUID = characteristicUUID
        self.assertValue = assertValue
    }
    
    
    public static let name = "read"
    public static let descriptionAttribute = "description"
    public static let serviceUUIDAttribute = "service-uuid"
    public static let serviceInstanceIDAttribute = "service-instance-id"
    public static let characteristicUUIDAttribute = "characteristic-uuid"
    public static let characteristicInstanceIDAttribute = "characteristic-instance-id"


    public static func parse(xml: Fuzi.XMLElement) -> Result<Read, MacroXMLError> {
        guard xml.tag == name else {
            return .failure(.unexpectedElement(expected: name, actual: xml.tag))
        }

        let description = xml.attr(descriptionAttribute)

        guard let serviceUUIDString = xml.attr(serviceUUIDAttribute) else {
            return .failure(.missingAttribute(element: xml.tag, attribute: serviceUUIDAttribute))
        }
        guard let serviceUUID = UUID(uuidString: serviceUUIDString) else {
            return .failure(.malformedUUIDAttribute(element: xml.tag, attribute: serviceUUIDAttribute, uuidString: serviceUUIDString))
        }

        guard let characteristicUUIDString = xml.attr(characteristicUUIDAttribute) else {
            return .failure(.missingAttribute(element: xml.tag, attribute: characteristicUUIDAttribute))
        }
        guard let characteristicUUID = UUID(uuidString: characteristicUUIDString) else {
            return .failure(.malformedUUIDAttribute(element: xml.tag, attribute: characteristicUUIDAttribute, uuidString: characteristicUUIDString))
        }

        return AssertValue.parse(childrenOf: xml).map { valueAsserts in
            return Read(
                description: description,
                serviceUUID: serviceUUID,
                characteristicUUID: characteristicUUID,
                assertValue: valueAsserts.first
            )
        }
    }
    
    
    public func xml() -> XMLElement {
        var attributes = [String: String]()
        
        if let description = description {
            attributes[Read.descriptionAttribute] = description
        }
        
        attributes[Read.serviceUUIDAttribute] = serviceUUID.uuidString
        attributes[Read.characteristicUUIDAttribute] = characteristicUUID.uuidString
        
        let children = assertValue.map { [$0.xml()] } ?? []
        
        return XMLElement(
            tag: Read.name,
            attributes: attributes,
            children: children
        )
    }
}
