import Foundation
import Combine
import BLEInternal
import CoreBluetoothTestable
import Logger


public protocol CentralManagerTasksProtocol {
    func connect(uuid: UUID) async -> Result<any PeripheralProtocol, DiscoveryError>
    func discover(uuid: UUID) async -> Result<any PeripheralProtocol, DiscoveryError>
}


public class CentralManagerTasks: CentralManagerTasksProtocol {
    private let logger: any LoggerProtocol
    private let centralManager: any CentralManagerProtocol
    
    
    public init(loggingBy logger: any LoggerProtocol, centralManager: any CentralManagerProtocol) {
        self.logger = logger
        self.centralManager = centralManager
    }
    
    
    open func connect(uuid: UUID) async -> Result<any PeripheralProtocol, DiscoveryError> {
        switch await discover(uuid: uuid) {
        case .failure(let error):
            return .failure(error)
        case .success(let peripheral):
            switch await waitConnected(peripheral: peripheral) {
            case .failure(let error):
                return .failure(error)
            case .success:
                return .success(peripheral)
            }
        }
    }
    
    
    private func waitConnected(peripheral: any PeripheralProtocol) async -> Result<Void, DiscoveryError> {
        return await withCheckedContinuation { continuation in
            var cancellables = Set<AnyCancellable>()
            
            self.centralManager.didConnectPeripheral
                .sink(receiveValue: { found in
                    guard found.identifier == peripheral.identifier else { return }
                    continuation.resume(returning: .success(()))
                    cancellables.removeAll()
                })
                .store(in: &cancellables)
            
            self.centralManager.didFailToConnectPeripheral
                .sink(receiveValue: { resp in
                    guard resp.peripheral.identifier == peripheral.identifier else { return }
                    continuation.resume(returning: .failure(.init(wrapping: resp.error)))
                    cancellables.removeAll()
                })
                .store(in: &cancellables)
            
            self.centralManager.connect(peripheral)
        }
    }

    
    public func discover(uuid: UUID) async -> Result<any PeripheralProtocol, DiscoveryError> {
        switch await waitUntilPowerOn() {
        case .failure(let error):
            return .failure(error)
        case .success:
            return await waitDiscover(uuid: uuid)
        }
    }
    
    
    private func waitDiscover(uuid: UUID, timeout: TimeInterval) async -> Result<any PeripheralProtocol, DiscoveryError> {
        let result = await Tasks.timeout(duration: timeout) {
            await self.waitDiscover(uuid: uuid)
        }
        switch result {
        case .failure(let error):
            return .failure(DiscoveryError(wrapping: error))
        case .success(.failure(let error)):
            return .failure(error)
        case .success(.success(let peripheral)):
            return .success(peripheral)
        }
    }
    
    
    private func waitDiscover(uuid: UUID) async -> Result<any PeripheralProtocol, DiscoveryError> {
        return await withCheckedContinuation { continuation in
            var cancellables = Set<AnyCancellable>()
            let centralManager = self.centralManager
            
            centralManager.didDiscoverPeripheral
                .handleEvents(receiveCancel: {
                    if centralManager.isScanning {
                        centralManager.stopScan()
                    }
                })
                .sink(receiveValue: { resp in
                    if resp.peripheral.identifier == uuid {
                        continuation.resume(returning: .success(resp.peripheral))
                        centralManager.stopScan()
                        cancellables.removeAll()
                    }
                })
                .store(in: &cancellables)
            
            centralManager.scanForPeripherals(withServices: nil)
        }
    }

    
    private func waitUntilPowerOn() async -> Result<Void, DiscoveryError> {
        return await withCheckedContinuation { continuation in
            var cancellables = Set<AnyCancellable>()
            let logger = self.logger
            
            self.centralManager.didUpdateState
                .sink(receiveValue: { state in
                    defer { cancellables.removeAll() }
                    
                    logger.debug("Bluetooth state: \(state)")
                    
                    switch state {
                    case .poweredOn:
                        continuation.resume(returning: .success(()))
                    case .poweredOff:
                        continuation.resume(returning: .failure(DiscoveryError(description: "Bluetooth is powered off")))
                    case .unauthorized:
                        continuation.resume(returning: .failure(DiscoveryError(description: "Bluetooth is unauthorized")))
                    case .unsupported:
                        continuation.resume(returning: .failure(DiscoveryError(description: "Bluetooth is unsupported")))
                    default:
                        logger.debug("Bluetooth state is not handled: \(state)")
                        break
                    }
                })
                .store(in: &cancellables)
        }
    }
}


public struct DiscoveryError: Error, CustomStringConvertible {
    public let description: String
    
    
    public init(description: String) {
        self.description = description
    }
    
    
    public init(wrapping error: any Error) {
        self.description = "\(error)"
    }
    
    
    public init(wrapping error: (any Error)?) {
        if let error = error {
            self.description = "\(error)"
        } else {
            self.description = "nil"
        }
    }
}
