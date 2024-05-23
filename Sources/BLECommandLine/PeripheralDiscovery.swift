import Foundation
import Combine
import SignalHandling
import ArgumentParser
import CoreBluetooth
import CoreBluetoothTestable
import BLEModel
import BLEInternal


struct PeripheralDiscovery: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "discover",
        abstract: "Discover peripherals"
    )
    
    
    @Option(name: .long, help: "Logging severity (available: \(LogSeverity.allCases.map(\.rawValue).joined(separator: "/"))).")
    var severity: String = LogSeverity.info.rawValue
    
    @Option(name: .long, help: "Service UUID. If empty, all services are discovered.")
    var service: String? = nil

    
    mutating func run() async throws {
        guard let severity = LogSeverity(rawValue: severity.lowercased()) else {
            fputs("error: invalid severity: \(severity)\n", stderr)
            throw ExitCode(1)
        }
        let logger = Logger(severity: severity, writer: ConsoleLogWriter.stderr)
        
        var serviceUUID: UUID? = nil
        if let service {
            guard let uuid = UUID(uuidString: service) else {
                fputs("error: invalid service UUID: \(service)\n", stderr)
                throw ExitCode(1)
            }
            serviceUUID = uuid
        }
        
        let discoverModel = PeripheralsDiscoveryModel(observingCentral: CentralManager(loggingBy: logger), searching: serviceUUID.map {[CBUUID(nsuuid: $0)]})
        discoverModel.stateDidUpdate.receive(subscriber: PeripheralsDiscoveryModelLogger(loggingBy: logger))
        
        let model = PeripheralsNewDiscoverModel(observing: discoverModel)
        try handleSigTerm()
        
        return await withCheckedContinuation { continuation in
            model.didDiscover
                .handleEvents(receiveCancel: {
                    print(toStdout: "")
                    continuation.resume()
                })
                .sink(receiveValue: { entry in
                    print(toStdout: "\(entry.uuid.uuidString)\t\(entry.peripheral.name ?? "(no name)")\t\(entry.rssi.description)")
                })
                .store(in: &cancellables)
                
            model.scan()
        }
    }
}

fileprivate var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()

fileprivate func handleSigTerm() throws {
    let action = Sigaction(handler: .ansiC({ sigID in
        cancellables.removeAll()
    }))
    
    try action.install(on: .interrupt)
}
