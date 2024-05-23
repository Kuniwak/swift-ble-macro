import Foundation


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


    public static func supported(xml: XMLElement) -> Bool {
        xml.name == name
    }


    public static func parse(xml: XMLElement) -> Result<AssertCharacteristic, MacroXMLError> {
        guard supported(xml: xml) else {
            return .failure(.unexpectedElement(expected: name, actual: xml.name))
        }

        let description = xml.attribute(forName: descriptionAttribute)?.stringValue

        guard let uuidString = xml.attribute(forName: uuidAttribute)?.stringValue else {
            return .failure(.missingAttribute(element: xml.name, attribute: uuidAttribute))
        }
        guard let uuid = UUID(uuidString: uuidString) else {
            return .failure(.malformedUUIDAttribute(element: uuidString, attribute: uuidAttribute, uuidString: uuidString))
        }

        var properties = [Property]()
        var assertDescriptors = [AssertDescriptor]()
        var assertCCCDs = [AssertCCCD]()

        for child in xml.children ?? [] {
            guard let element = child as? XMLElement else { continue }
            
            switch element.name {
            case Property.name:
                switch Property.parse(xml: element) {
                case .failure(let error):
                    return .failure(error)
                case .success(let property):
                    properties.append(property)
                }
            case AssertDescriptor.name:
                switch AssertDescriptor.parse(xml: element) {
                case .failure(let error):
                    return .failure(error)
                case .success(let descriptor):
                    assertDescriptors.append(descriptor)
                }
            case AssertCCCD.name:
                switch AssertCCCD.parse(xml: element) {
                case .failure(let error):
                    return .failure(error)
                case .success(let cccd):
                    assertCCCDs.append(cccd)
                }
            default:
                return .failure(.notSupportedChildElement(parent: xml.name, child: element.name))
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
        let element = XMLElement(name: AssertCharacteristic.name)

        if let description = description {
            let descAttr = XMLNode(kind: .attribute)
            descAttr.name = AssertCharacteristic.descriptionAttribute
            descAttr.stringValue = description
            element.addAttribute(descAttr)
        }

        let uuidAttr = XMLNode(kind: .attribute)
        uuidAttr.name = AssertCharacteristic.uuidAttribute
        uuidAttr.stringValue = uuid.uuidString
        element.addAttribute(uuidAttr)

        let children = properties.map { $0.xml() } + assertDescriptors.map { $0.xml() } + (assertCCCD.map { [$0.xml()] } ?? [])
        for child in children {
            element.addChild(child)
        }
        return element
    }
}
