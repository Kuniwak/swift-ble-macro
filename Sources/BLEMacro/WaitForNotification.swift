import struct Foundation.UUID
import Fuzi


public struct WaitForNotification: Equatable {
    public let description: String?
    public let serviceUUID: UUID
    public let characteristicUUID: UUID
    
    
    public init (
        description: String? = nil,
        serviceUUID: UUID,
        characteristicUUID: UUID,
        assertValue: AssertValue? = nil
    ) {
        self.description = description
        self.serviceUUID = serviceUUID
        self.characteristicUUID = characteristicUUID
    }
    
    
    public static let name = "wait-for-notification"
    public static let descriptionAttribute = "description"
    public static let serviceUUIDAttribute = "service-uuid"
    public static let characteristicUUIDAttribute = "characteristic-uuid"
    
    
    public static func parse(xml: Fuzi.XMLElement) -> Result<WaitForNotification, MacroXMLError> {
        guard xml.tag == name else {
            return .failure(.unexpectedElement(expected: WaitForNotification.name, actual: xml.tag))
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
            return WaitForNotification(
                description: description,
                serviceUUID: serviceUUID,
                characteristicUUID: characteristicUUID,
                assertValue: valueAsserts.first
            )
        }
    }
}
