import Foundation


public struct Sleep: Equatable {
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
    
    
    public static func supported(xml: XMLElement) -> Bool {
        xml.name == name
    }
    
    
    public static func parse(xml: XMLElement) -> Result<Sleep, MacroXMLError> {
        guard xml.name == name else {
            return .failure(.unexpectedElement(expected: Sleep.name, actual: xml.name))
        }
        
        let description = xml.attribute(forName: descriptionAttribute)?.stringValue
        
        guard let timeoutString = xml.attribute(forName: timeoutAttribute)?.stringValue else {
            return .failure(.missingAttribute(element: xml.name, attribute: timeoutAttribute))
        }
        guard let timeout = UInt(timeoutString) else {
            return .failure(.malformedSleepTimeoutAttribute(element: xml.name, timeoutString: timeoutString))
        }
        
        return .success(
            Sleep(
                description: description,
                timeout: timeout
            )
        )
    }
}
