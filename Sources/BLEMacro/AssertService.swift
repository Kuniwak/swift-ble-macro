import struct Foundation.UUID
import Fuzi
import BLEInternal


public struct AssertService: Equatable, Codable, Sendable {
    public let description: String?
    public let uuid: UUID
    public let assertCharacteristics: [AssertCharacteristic]


    public init(
        description: String? = nil,
        uuid: UUID,
        characteristicAsserts: [AssertCharacteristic] = []
    ) {
        self.description = description
        self.uuid = uuid
        self.assertCharacteristics = characteristicAsserts
    }


    public static let name = "assert-service"
    public static let descriptionAttribute = "description"
    public static let uuidAttribute = "uuid"


    public static func parse(xml: Fuzi.XMLElement) -> Result<AssertService, MacroXMLError> {
        guard xml.tag == name else {
            return .failure(.unexpectedElement(expected: AssertService.name, actual: xml.tag))
        }

        let description = xml.attr(descriptionAttribute)
        guard let uuidString = xml.attr(uuidAttribute) else {
            return .failure(.missingAttribute(element: xml.tag, attribute: uuidAttribute))
        }
        guard let uuid = UUID(uuidString: uuidString) else {
            return .failure(.malformedUUIDAttribute(element: uuidString, attribute: uuidAttribute, uuidString: uuidString))
        }

        let characteristicAssertResults = xml.children.compactMap { child -> Result<AssertCharacteristic, MacroXMLError>? in
            return AssertCharacteristic.parse(xml: child)
        }

        return Results.combineAll(characteristicAssertResults).map { characteristicAsserts in
            return AssertService(
                description: description,
                uuid: uuid,
                characteristicAsserts: characteristicAsserts
            )
        }
    }


    public func xml() -> XMLElement {
        var attributes = [String: String]()
        
        if let description = description {
            attributes[AssertService.descriptionAttribute] = description
        }
        
        attributes[AssertService.uuidAttribute] = uuid.uuidString
        
        return XMLElement(tag: AssertService.name, attributes: attributes, children: assertCharacteristics.map { $0.xml() })
    }
}
