public enum UUIDCollectionDiscoveryError: Error, Equatable {
    case couldNotFindRepository(path: String)
    case uuidsDirectoryDoesNotExist(path: String)
    case couldNotReadDirectory(path: String, error: String)
}
