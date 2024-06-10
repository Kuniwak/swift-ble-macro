import struct Foundation.UUID
import Fuzi


public struct AssertCharacteristic: Equatable {
    public let description: String?
    public let uuid: UUID
    public let properties: [Property]
    public let assertDescriptors: [AssertDescriptor]
    public let assertCCCD: AssertCCCD?


    public init(
        description: String? = nil,
        uuid: UUID,
        properties: [Property] = [],
        assertDescriptors: [AssertDescriptor] = [],
        assertCCCD: AssertCCCD? = nil
    ) {
        self.description = description
        self.uuid = uuid
        self.properties = properties
        self.assertDescriptors = assertDescriptors
        self.assertCCCD = assertCCCD
    }


    public static let name = "assert-characteristic"
    public static let descriptionAttribute = "description"
    public static let uuidAttribute = "uuid"


    public static func parse(xml: Fuzi.XMLElement) -> Result<AssertCharacteristic, MacroXMLError> {
        guard xml.tag == name else {
            return .failure(.unexpectedElement(expected: name, actual: xml.tag))
        }

        let description = xml.attr(descriptionAttribute)

        guard let uuidString = xml.attr(uuidAttribute) else {
            return .failure(.missingAttribute(element: xml.tag, attribute: uuidAttribute))
        }
        guard let uuid = UUID(uuidString: uuidString) else {
            return .failure(.malformedUUIDAttribute(element: uuidString, attribute: uuidAttribute, uuidString: uuidString))
        }

        var properties = [Property]()
        var assertDescriptors = [AssertDescriptor]()
        var assertCCCDs = [AssertCCCD]()

        for child in xml.children {
            switch child.tag {
            case Property.name:
                switch Property.parse(xml: child) {
                case .failure(let error):
                    return .failure(error)
                case .success(let property):
                    properties.append(property)
                }
            case AssertDescriptor.name:
                switch AssertDescriptor.parse(xml: child) {
                case .failure(let error):
                    return .failure(error)
                case .success(let descriptor):
                    assertDescriptors.append(descriptor)
                }
            case AssertCCCD.name:
                switch AssertCCCD.parse(xml: child) {
                case .failure(let error):
                    return .failure(error)
                case .success(let cccd):
                    assertCCCDs.append(cccd)
                }
            default:
                return .failure(.notSupportedChildElement(parent: xml.tag, child: child.tag))
            }
        }
        return .success(
            AssertCharacteristic(
                description: description,
                uuid: uuid,
                properties: properties,
                assertDescriptors: assertDescriptors,
                assertCCCD: assertCCCDs.first
            )
        )
    }


    public func xml() -> XMLElement {
        var attributes = [String: String]()
        
        if let description = description {
            attributes[AssertCharacteristic.descriptionAttribute] = description
        }
        
        return XMLElement(
            tag: AssertCharacteristic.name,
            attributes: attributes,
            children: properties.map { $0.xml() } + assertDescriptors.map { $0.xml() } + (assertCCCD != nil ? [assertCCCD!.xml()] : [])
        )
    }
}
