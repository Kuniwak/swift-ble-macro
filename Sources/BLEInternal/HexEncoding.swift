import Foundation


public enum HexEncoding: String, Equatable, Codable, Sendable {
    case upper = "%02hhX"
    case lower = "%02hhx"

    
    public func encode(data: Data) -> String {
        return data.map { String(format: rawValue, $0) }.joined()
    }
    

    public static func decode(hexString: String) -> Result<(data: Data, encoding: HexEncoding), HexEncodingError> {
        let encoding = hexString.contains(where: { $0.isUppercase }) ? HexEncoding.upper : HexEncoding.lower
        guard hexString.count % 2 == 0 else {
            return .failure(.oddNumberOfCharacters(hexString: hexString))
        }
        var data = Data(capacity: hexString.count / 2)

        var index = hexString.startIndex
        while index < hexString.endIndex {
            let nextIndex = hexString.index(index, offsetBy: 2)
            guard let byte = UInt8(hexString[index..<nextIndex], radix: 16) else {
                return .failure(.invalidCharacter(hexString: hexString))
            }
            data.append(byte)
            index = nextIndex
        }
        return .success((data: data, encoding: encoding))
    }
}
