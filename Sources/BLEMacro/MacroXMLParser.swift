import Foundation

public enum MacroXMLParser {
    public static func parse(xml: XMLDocument) -> Result<Macro, MacroXMLError> {
        guard let root = xml.rootElement() else {
            return .failure(.noRootElement)
        }

        return Macro.parse(xml: root)
    }
}
