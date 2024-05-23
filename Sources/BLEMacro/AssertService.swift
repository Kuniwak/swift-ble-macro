import Foundation
import BLEInternal


public struct AssertService: Equatable {
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


    public static func parse(xml: XMLElement) -> Result<AssertService, MacroXMLError> {
        guard xml.name == name else {
            return .failure(.unexpectedElement(expected: AssertService.name, actual: xml.name))
        }

        let description = xml.attribute(forName: descriptionAttribute)?.stringValue
        guard let uuidString = xml.attribute(forName: uuidAttribute)?.stringValue else {
            return .failure(.missingAttribute(element: xml.name, attribute: uuidAttribute))
        }
        guard let uuid = UUID(uuidString: uuidString) else {
            return .failure(.malformedUUIDAttribute(element: uuidString, attribute: uuidAttribute, uuidString: uuidString))
        }

        let characteristicAssertResults = (xml.children ?? []).compactMap { child -> Result<AssertCharacteristic, MacroXMLError>? in
            guard let element = child as? XMLElement else {
                return nil
            }
            return AssertCharacteristic.parse(xml: element)
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
        let element = XMLElement(name: AssertService.name)

        if let description = description {
            let descAttr = XMLNode(kind: .attribute)
            descAttr.name = AssertService.descriptionAttribute
            descAttr.stringValue = description
            element.addAttribute(descAttr)
        }

        let uuidAttr = XMLNode(kind: .attribute)
        uuidAttr.name = AssertService.uuidAttribute
        uuidAttr.stringValue = uuid.uuidString
        element.addAttribute(uuidAttr)

        element.setChildren(assertCharacteristics.map { $0.xml() })
        return element
    }
}
