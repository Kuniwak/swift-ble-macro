import Foundation


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
    
    
    public static func parse(xml: XMLElement) -> Result<WaitForNotification, MacroXMLError> {
        guard xml.name == name else {
            return .failure(.unexpectedElement(expected: WaitForNotification.name, actual: xml.name))
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
            return WaitForNotification(
                description: description,
                serviceUUID: serviceUUID,
                characteristicUUID: characteristicUUID,
                assertValue: valueAsserts.first
            )
        }
    }
}
