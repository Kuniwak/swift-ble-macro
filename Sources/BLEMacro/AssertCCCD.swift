import Foundation


public struct AssertCCCD: Equatable {
    public let description: String?


    public init(description: String? = nil) {
        self.description = description
    }


    public static let name = "assert-cccd"
    public static let descriptionAttribute = "description"


    public static func parse(xml: XMLElement) -> Result<AssertCCCD, MacroXMLError> {
        guard xml.name == name else {
            return .failure(.unexpectedElement(expected: name, actual: xml.name))
        }

        let description = xml.attribute(forName: descriptionAttribute)?.stringValue

        return .success(AssertCCCD(description: description))
    }


    public func xml() -> XMLElement {
        let element = XMLElement(name: AssertCCCD.name)
        if let description {
            let descAttr = XMLNode(kind: .attribute)
            descAttr.name = AssertCCCD.descriptionAttribute
            descAttr.stringValue = description
            element.addAttribute(descAttr)
        }
        return element
    }
}
