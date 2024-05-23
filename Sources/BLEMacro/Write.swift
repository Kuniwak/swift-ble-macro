import Foundation


public struct Write: Equatable {
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
    
    
    public static func parse(xml: XMLElement) -> Result<Write, MacroXMLError> {
        guard xml.name == name else {
            return .failure(.unexpectedElement(expected: Write.name, actual: xml.name))
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
}
