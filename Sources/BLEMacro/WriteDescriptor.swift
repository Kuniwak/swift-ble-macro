import struct Foundation.UUID
import Fuzi


public struct WriteDescriptor: Equatable {
    public let description: String?
    public let uuid: UUID
    public let serviceUUID: UUID
    public let characteristicUUID: UUID
    public let value: Value
    
    
    public init(
        description: String? = nil,
        uuid: UUID,
        serviceUUID: UUID,
        characteristicUUID: UUID,
        value: Value
    ) {
        self.description = description
        self.uuid = uuid
        self.serviceUUID = serviceUUID
        self.characteristicUUID = characteristicUUID
        self.value = value
    }
    
    
    public static let name = "write-descriptor"
    public static let descriptionAttribute = "description"
    public static let descriptorUUIDAttribute = "uuid"
    public static let serviceUUIDAttribute = "service-uuid"
    public static let characteristicUUIDAttribute = "characteristic-uuid"
    
    
    public static func parse(xml: Fuzi.XMLElement) -> Result<WriteDescriptor, MacroXMLError> {
        guard xml.tag == name else {
            return .failure(.unexpectedElement(expected: name, actual: xml.tag))
        }
        
        let description = xml.attr(descriptionAttribute)
        
        guard let descriptorUUIDString = xml.attr(descriptorUUIDAttribute) else {
            return .failure(.missingAttribute(element: xml.tag, attribute: descriptorUUIDAttribute))
        }
        guard let uuid = UUID(uuidString: descriptorUUIDString) else {
            return .failure(.malformedUUIDAttribute(element: xml.tag, attribute: descriptorUUIDAttribute, uuidString: descriptorUUIDString))
        }
        
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
        
        return Value.parse(xml: xml).map { value in
            return WriteDescriptor(
                description: description,
                uuid: uuid,
                serviceUUID: serviceUUID,
                characteristicUUID: characteristicUUID,
                value: value
            )
        }
    }
    
    
    public func xml() -> XMLElement {
        var attributes = [String: String]()
        
        if let description = description {
            attributes[WriteDescriptor.descriptionAttribute] = description
        }
        
        attributes[WriteDescriptor.descriptorUUIDAttribute] = uuid.uuidString
        attributes[WriteDescriptor.serviceUUIDAttribute] = serviceUUID.uuidString
        attributes[WriteDescriptor.characteristicUUIDAttribute] = characteristicUUID.uuidString
        value.addAttribute(to: &attributes)
        
        return XMLElement(
            tag: WriteDescriptor.name,
            attributes: attributes,
            children: []
        )
    }
}
