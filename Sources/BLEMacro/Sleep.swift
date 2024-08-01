import Fuzi


public struct Sleep: Equatable, Codable, Sendable {
    public let description: String?
    public let timeout: UInt
    
    
    public init(
        description: String?,
        timeout: UInt
    ) {
        self.description = description
        self.timeout = timeout
    }
    
    
    public static let name = "sleep"
    public static let descriptionAttribute = "description"
    public static let timeoutAttribute = "timeout"
    
    
    public static func parse(xml: Fuzi.XMLElement) -> Result<Sleep, MacroXMLError> {
        guard xml.tag == name else {
            return .failure(.unexpectedElement(expected: Sleep.name, actual: xml.tag))
        }
        
        let description = xml.attr(descriptionAttribute)
        
        guard let timeoutString = xml.attr(timeoutAttribute) else {
            return .failure(.missingAttribute(element: xml.tag, attribute: timeoutAttribute))
        }
        guard let timeout = UInt(timeoutString) else {
            return .failure(.malformedSleepTimeoutAttribute(element: xml.tag, timeoutString: timeoutString))
        }
        
        return .success(
            Sleep(
                description: description,
                timeout: timeout
            )
        )
    }
    
    
    public func xml() -> MacroXMLElement {
        var attributes = [MacroXMLAttribute]()
        
        if let description = description {
            attributes.append(MacroXMLAttribute(name: Sleep.descriptionAttribute, value: description))
        }
        
        attributes.append(MacroXMLAttribute(name: Sleep.timeoutAttribute, value: String(timeout)))
        
        return MacroXMLElement(
            tag: Sleep.name,
            attributes: attributes,
            children: []
        )
    }
}


extension Sleep: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "(description: \(description ?? "nil"), timeout: \(timeout))"
    }
}
