import Foundation
import Yams


public struct UUIDCollection: Equatable {
    public let url: URL
    public let entries: [UUIDCollectionEntry]
    
    
    public init(url: URL, entries: [UUIDCollectionEntry]) {
        self.url = url
        self.entries = entries
    }
    
    
    public static func parse(fromYAML yamlString: String, atURL url: URL) -> Result<UUIDCollection, UUIDCollectionError> {
        do {
            let loaded = try Yams.load(yaml: yamlString)
            return parse(fromDictionary: loaded, atURL: url)
        } catch (let e) {
            return .failure(.parseError("\(e)"))
        }
    }
    
    
    public static func parse(fromDictionary dictionary: Any?, atURL url: URL) -> Result<UUIDCollection, UUIDCollectionError> {
        guard let root = dictionary as? [String: Any] else {
            return .failure(.notDictionary)
        }
        
        guard let uuids = root["uuids"] else {
            return .failure(.missingUUIDs)
        }
        
        guard let uuids = uuids as? Array<Any> else {
            return .failure(.UUIDsIsNotArray)
        }
        
        var entries: [UUIDCollectionEntry] = []
        for uuid in uuids {
            let entry = UUIDCollectionEntry.parse(fromDictionary: uuid)
            switch entry {
            case .success(let entry):
                entries.append(entry)
            case .failure(let error):
                return .failure(error)
            }
        }
        return .success(UUIDCollection(url: url, entries: entries))
    }
    
    
    public static func build(fromYAMLURL url: URL) -> Result<UUIDCollection, UUIDCollectionError> {
        do {
            let yamlString = try String(contentsOf: url)
            return parse(fromYAML: yamlString, atURL: url)
        } catch (let e) {
            return .failure(.readError("\(e)"))
        }
    }
    
    
    public static func build(fromRepoURL url: URL) -> Result<[UUIDCollection], UUIDCollectionError> {
        let discovery = UUIDCollectionDiscovery(fileManager: FileManager.default)
        let result = discovery.discover(fromRepository: url)
        switch result {
        case .failure(let e):
            return .failure(.discoveryError("\(e)"))
        case .success(let urls):
            var collections: [UUIDCollection] = []
            for url in urls {
                let collection = build(fromYAMLURL: url)
                switch collection {
                case .failure(let e):
                    return .failure(e)
                case .success(let collection):
                    collections.append(collection)
                }
            }
            return .success(collections)
        }
    }
}
