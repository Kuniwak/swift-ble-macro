import Foundation


public struct AssertDescriptor: Equatable {
    public let description: String?
    public let uuid: UUID

    public init(
        description: String?,
        uuid: UUID
    ) {
        self.description = description
        self.uuid = uuid
    }


    public static let name = "assert-descriptor"
    public static let descriptionAttribute = "description"
    public static let uuidAttribute = "uuid"
    public static let instanceIDAttribute = "instance-id"


    public static func parse(xml: XMLElement) -> Result<AssertDescriptor, MacroXMLError> {
        guard xml.name == name else {
            return .failure(.unexpectedElement(expected: AssertDescriptor.name, actual: xml.name))
        }

        let description = xml.attribute(forName: descriptionAttribute)?.stringValue

        guard let uuidString = xml.attribute(forName: uuidAttribute)?.stringValue else {
            return .failure(.missingAttribute(element: xml.name, attribute: uuidAttribute))
        }
        guard let uuid = UUID(uuidString: uuidString) else {
            return .failure(.malformedUUIDAttribute(element: uuidString, attribute: uuidAttribute, uuidString: uuidString))
        }

        return .success(
            AssertDescriptor(
                description: description,
                uuid: uuid
            )
        )
    }


    public func xml() -> XMLElement {
        let element = XMLElement(name: AssertDescriptor.name)

        if let description {
            let descAttr = XMLNode(kind: .attribute)
            descAttr.name = AssertDescriptor.descriptionAttribute
            descAttr.stringValue = description
            element.addAttribute(descAttr)
        }

        let uuidAttr = XMLNode(kind: .attribute)
        uuidAttr.name = AssertDescriptor.uuidAttribute
        uuidAttr.stringValue = uuid.uuidString
        element.addAttribute(uuidAttr)

        return element
    }
}
