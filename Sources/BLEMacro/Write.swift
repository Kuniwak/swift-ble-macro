import struct Foundation.UUID
import Fuzi


public struct Write: Equatable, Codable, Sendable {
    public let description: String?
    public let serviceUUID: UUID
    public let characteristicUUID: UUID
    public let type: WritingType
    public let value: Value
    
    
    public init(
        description: String? = nil,
        serviceUUID: UUID,
        characteristicUUID: UUID,
        type: WritingType,
        value: Value
    ) {
        self.description = description
        self.serviceUUID = serviceUUID
        self.characteristicUUID = characteristicUUID
        self.type = type
        self.value = value
    }
    
    
    public static let name = "write"
    public static let descriptionAttribute = "description"
    public static let serviceUUIDAttribute = "service-uuid"
    public static let characteristicUUIDAttribute = "characteristic-uuid"
    public static let typeAttribute = "type"
    public static let valueAttribute = "value"
    
    
    public static func parse(xml: Fuzi.XMLElement) -> Result<Write, MacroXMLError> {
        guard xml.tag == name else {
            return .failure(.unexpectedElement(expected: Write.name, actual: xml.tag))
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
        
        switch (WritingType.parse(xml: xml), Value.parse(xml: xml)) {
        case (.failure(let error), _):
            return .failure(error)
        case (_, .failure(let error)):
            return .failure(error)
        case (.success(let type), .success(let value)):
            return .success(Write(
                description: description,
                serviceUUID: serviceUUID,
                characteristicUUID: characteristicUUID,
                type: type,
                value: value
            ))
        }
    }
    
    
    public func xml() -> MacroXMLElement {
        var attributes = [MacroXMLAttribute]()
        
        if let description = description {
            attributes.append(MacroXMLAttribute(name: Write.descriptionAttribute, value: description))
        }
        
        attributes.append(MacroXMLAttribute(name: Write.serviceUUIDAttribute, value: serviceUUID.uuidString))
        attributes.append(MacroXMLAttribute(name: Write.characteristicUUIDAttribute, value: characteristicUUID.uuidString))
        attributes.append(type.xmlAttribute())
        attributes.append(value.xmlAttribute())
        
        return MacroXMLElement(
            tag: Write.name,
            attributes: attributes,
            children: []
        )
    }
}


extension Write: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "(description: \(description ?? "nil"), serviceUUID: \(serviceUUID.uuidString), characteristicUUID: \(characteristicUUID.uuidString), type: \(type), value: \(value.debugDescription))"
    }
}
