import Fuzi


public struct Macro: Equatable {
    public let name: String
    public let icon: Icon
    public let assertServices: [AssertService]
    public let operations: [Operation]


    public init(
        name: String,
        icon: Icon,
        assertServices: [AssertService] = [],
        operations: [Operation] = []
    ) {
        self.name = name
        self.icon = icon
        self.assertServices = assertServices
        self.operations = operations
    }


    public static let name = "macro"
    public static let nameAttribute = "name"
    public static let iconAttribute = "icon"


    public static func parse(xml: Fuzi.XMLElement) -> Result<Macro, MacroXMLError> {
        guard xml.tag == name else {
            return .failure(.unexpectedElement(expected: name, actual: xml.tag))
        }

        guard let name = xml.attr(nameAttribute) else {
            return .failure(.missingAttribute(element: xml.tag, attribute: nameAttribute))
        }

        var assertServices = [AssertService]()
        var operations = [Operation]()
        
        for child in xml.children {
            switch child.tag {
            case AssertService.name:
                switch AssertService.parse(xml: child) {
                case .success(let serviceAssert):
                    assertServices.append(serviceAssert)
                case .failure(let error):
                    return .failure(error)
                }
            default:
                switch Operation.parse(xml: child) {
                case .success(let operation):
                    operations.append(operation)
                case .failure(let error):
                    return .failure(error)
                }
            }
        }


        return Icon.parse(xml: xml).map { icon in
            Macro(
                name: name,
                icon: icon,
                assertServices: assertServices,
                operations: operations
            )
        }
    }
}
