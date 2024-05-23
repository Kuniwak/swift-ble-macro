import Foundation
import BLEAssignedNumbers


public enum UUIDs {
    public static func from(toOptional string: String) -> UUID? {
        switch from(toResult: string) {
        case .failure:
            return nil
        case .success(let uuid):
            return uuid
        }
    }
    
    
    public static func from(toResult string: String) -> Result<UUID, UUIDError> {
        if let uuid = UUID(uuidString: string) {
            return .success(uuid)
        }
        
        switch HexEncoding.decode(hexString: string) {
        case .failure(let error):
            return .failure(UUIDError(wrapping: error))
        case .success((data: let data, _)):
            switch data.count {
            case 2:
                return .success(uuid16Bits(data[0], data[1]))
            case 4:
                return .success(uuid32Bits(data[0], data[1], data[2], data[3]))
            default:
                return .failure(UUIDError("invalid UUID: \(string)"))
            }
        }
    }
}
