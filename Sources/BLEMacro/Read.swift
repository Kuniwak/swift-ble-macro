import Foundation


public struct Read: Equatable {
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


    public static func parse(xml: XMLElement) -> Result<Read, MacroXMLError> {
        guard xml.name == name else {
            return .failure(.unexpectedElement(expected: name, actual: xml.name))
        }

        let description = xml.attribute(forName: descriptionAttribute)?.stringValue

        guard let serviceUUIDString = xml.attribute(forName: serviceUUIDAttribute)?.stringValue else {
            return .failure(.missingAttribute(element: xml.name, attribute: serviceUUIDAttribute))
        }
        guard let serviceUUID = UUID(uuidString: serviceUUIDString) else {
            return .failure(.malformedUUIDAttribute(element: xml.name, attribute: serviceUUIDAttribute, uuidString: serviceUUIDString))
        }

        guard let characteristicUUIDString = xml.attribute(forName: characteristicUUIDAttribute)?.stringValue else {
            return .failure(.missingAttribute(element: xml.name, attribute: characteristicUUIDAttribute))
        }
        guard let characteristicUUID = UUID(uuidString: characteristicUUIDString) else {
            return .failure(.malformedUUIDAttribute(element: xml.name, attribute: characteristicUUIDAttribute, uuidString: characteristicUUIDString))
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
        let element = XMLElement(name: Read.name)
        
        if let description {
            let attr = XMLNode(kind: .attribute)
            attr.name = Read.descriptionAttribute
            attr.stringValue = description
            element.addAttribute(attr)
        }
        
        let serviceUUIDAttr = XMLNode(kind: .attribute)
        serviceUUIDAttr.name = Read.serviceUUIDAttribute
        serviceUUIDAttr.stringValue = serviceUUID.uuidString
        element.addAttribute(serviceUUIDAttr)
        
        let characteristicUUIDAttr = XMLNode(kind: .attribute)
        characteristicUUIDAttr.name = Read.characteristicUUIDAttribute
        characteristicUUIDAttr.stringValue = characteristicUUID.uuidString
        element.addAttribute(characteristicUUIDAttr)
        
        return element
    }
}
