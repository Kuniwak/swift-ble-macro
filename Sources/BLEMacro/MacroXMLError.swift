import BLEInternal


public enum MacroXMLError: Error, Equatable, Codable, Sendable {
    case bothValueAndValueStringAttributesPresent(element: String?)
    case malformedSleepTimeoutAttribute(element: String?, timeoutString: String)
    case malformedUUIDAttribute(element: String?, attribute: String, uuidString: String)
    case malformedValueAttribute(hexEncodingError: HexEncodingError)
    case missingAttribute(element: String?, attribute: String)
    case missingValueOrValueStringAttribute(name: String?)
    case noRootElement
    case notSupportedChildElement(parent: String?, child: String?)
    case notSupportedIcon(icon: String)
    case notSupportedOperation(element: String?)
    case notSupportedProperty(name: String)
    case notSupportedRequirement(value: String)
    case notSupportedType(element: String?, type: String?)
    case unexpectedElement(expected: String, actual: String?)
}
