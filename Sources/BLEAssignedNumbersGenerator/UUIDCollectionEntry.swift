public struct UUIDCollectionEntry: Equatable {
    public let name: String
    public let id: String?
    public let uuidByte3: UInt8
    public let uuidByte4: UInt8
    
    
    public init(name: String, id: String?, uuid: (UInt8, UInt8)) {
        self.name = name
        self.id = id
        self.uuidByte3 = uuid.0
        self.uuidByte4 = uuid.1
    }
    
    
    public static func parse(fromDictionary dictionary: Any?) -> Result<UUIDCollectionEntry, UUIDCollectionError> {
        guard let entry = dictionary as? [String: Any] else {
            return .failure(.notDictionary)
        }
        
        guard let name = entry["name"] else {
            return .failure(.missingName)
        }
        
        guard let name = name as? String else {
            return .failure(.nameIsNotString)
        }
        
        let optionalID: String?
        if let id = entry["id"] {
            guard let id = id as? String else {
                return .failure(.IDIsNotString)
            }
            optionalID = id
        } else {
            optionalID = nil
        }
        
        guard let uuid = entry["uuid"] else {
            return .failure(.missingUUID)
        }
        
        guard let uuid = uuid as? Int else {
            return .failure(.UUIDIsNotString)
        }
        
        let uuid1 = UInt8((uuid >> 8) & 0xFF)
        let uuid2 = UInt8(uuid & 0xFF)
        
        return .success(UUIDCollectionEntry(name: name, id: optionalID, uuid: (uuid1, uuid2)))
    }
}
