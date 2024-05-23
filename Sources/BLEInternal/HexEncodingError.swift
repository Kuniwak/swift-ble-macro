public enum HexEncodingError: Error, Equatable {
    case oddNumberOfCharacters(hexString: String)
    case invalidCharacter(hexString: String)
    case mixedCase(hexString: String)
}


extension HexEncodingError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .oddNumberOfCharacters(let hexString):
            return "The string \(hexString) has an odd number of characters."
        case .invalidCharacter(let hexString):
            return "The string \(hexString) contains an invalid character."
        case .mixedCase(let hexString):
            return "The string \(hexString) contains a mix of upper and lower case characters."
        }
    }
}
