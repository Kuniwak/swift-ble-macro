import Foundation


public enum NameNormalization {
    private static let json = JSONEncoder()
    
    
    public static func escapeDoubleQuotes(_ str: String) -> String {
        json.outputFormatting = .withoutEscapingSlashes
        return String(data: try! json.encode(str), encoding: .utf8)!
    }
    
    
    public static func lowerCamelCase(words: [some StringProtocol]) -> String {
        return words
            .enumerated()
            .map { $0.offset > 0 ? $0.element.capitalized : $0.element.lowercased() }
            .joined()
    }
    
    
    public static func upperCamelCase(words: [some StringProtocol]) -> String {
        return words
            .map(\.capitalized)
            .joined()
    }
}
