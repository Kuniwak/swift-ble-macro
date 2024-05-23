import Foundation
import ArgumentParser
import Darwin


@main
struct BLEAssignedNumbersGenerator: ParsableCommand {
    @Argument(help: "Path to Bluetooth_SIG/BluetoothSIGPublic/public")
    var repoRootPath: String
    
    mutating func run() throws {
        let repoRoot = URL(fileURLWithPath: repoRootPath)
        
        switch UUIDCollectionDiscovery(fileManager: .default).discover(fromRepository: repoRoot) {
        case .failure(let error):
            fputs("error: \(error)\n", stderr)
            throw ExitCode(1)
        case .success(let urls):
            var collections = [UUIDCollection]()
            for url in urls {
                fputs("info: found: \(url.absoluteString)\n", stderr)
                switch UUIDCollection.build(fromYAMLURL: url) {
                case .failure(let error):
                    fputs("error: \(error)\n", stderr)
                    throw ExitCode(1)
                case .success(let collection):
                    collections.append(collection)
                }
            }
            
            switch CodeGeneration.generate(fromCollections: collections) {
            case .failure(let error):
                fputs("error: \(error)\n", stderr)
                throw ExitCode(1)
            case .success(let code):
                fputs(code, stdout)
            }
        }
    }
}
