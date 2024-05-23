import Foundation


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
    
    
    public static func parse(xml: XMLElement) -> Result<WriteDescriptor, MacroXMLError> {
        guard xml.name == name else {
            return .failure(.unexpectedElement(expected: name, actual: xml.name))
        }
        
        let description = xml.attribute(forName: descriptionAttribute)?.stringValue
        
        guard let descriptorUUIDString = xml.attribute(forName: descriptorUUIDAttribute)?.stringValue else {
            return .failure(.missingAttribute(element: xml.name, attribute: descriptorUUIDAttribute))
        }
        guard let uuid = UUID(uuidString: descriptorUUIDString) else {
            return .failure(.malformedUUIDAttribute(element: xml.name, attribute: descriptorUUIDAttribute, uuidString: descriptorUUIDString))
        }
        
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
        let element = XMLElement(name: WriteDescriptor.name)
        
        if let description = description {
            let attr = XMLNode(kind: .attribute)
            attr.name = WriteDescriptor.descriptionAttribute
            attr.stringValue = description
            element.addAttribute(attr)
        }
        
        let uuidAttr = XMLNode(kind: .attribute)
        uuidAttr.name = WriteDescriptor.descriptorUUIDAttribute
        uuidAttr.stringValue = uuid.uuidString
        element.addAttribute(uuidAttr)
        
        let serviceUUIDAttr = XMLNode(kind: .attribute)
        serviceUUIDAttr.name = WriteDescriptor.serviceUUIDAttribute
        serviceUUIDAttr.stringValue = serviceUUID.uuidString
        element.addAttribute(serviceUUIDAttr)
        
        let characteristicUUIDAttr = XMLNode(kind: .attribute)
        characteristicUUIDAttr.name = WriteDescriptor.characteristicUUIDAttribute
        characteristicUUIDAttr.stringValue = characteristicUUID.uuidString
        element.addAttribute(characteristicUUIDAttr)
        
        value.addAttribute(toElement: element)
        return element
    }
}
