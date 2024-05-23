public enum UUIDCollectionError: Error, Equatable {
    case readError(String)
    case parseError(String)
    case discoveryError(String)
    case notDictionary
    case missingUUIDs
    case missingUUID
    case UUIDsIsNotArray
    case missingName
    case nameIsNotString
    case IDIsNotString
    case UUIDIsNotString
}
