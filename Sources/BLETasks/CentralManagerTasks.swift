import Foundation
import Combine
import BLEInternal
import CoreBluetoothTestable
import Logger


public protocol CentralManagerTasksProtocol {
    func connect(uuid: UUID) async -> Result<any PeripheralProtocol, CentralManagerTaskFailure>
    func discover(uuid: UUID) async -> Result<any PeripheralProtocol, CentralManagerTaskFailure>
}


public struct CentralManagerTaskFailure: Error, Equatable, Sendable, Codable, CustomStringConvertible {
    public let description: String
    
    
    public init(_ description: String) {
        self.description = description
    }
    
    
    public init(wrapping error: any Error) {
        self.description = "\(error)"
    }
    
    
    public init(wrapping error: (any Error)?) {
        self.description = error.map { "\($0)" } ?? "nil"
    }
}


public class CentralManagerTasks: CentralManagerTasksProtocol {
    private let centralManager: any CentralManagerProtocol
    
    
    public init(centralManager: any CentralManagerProtocol) {
        self.centralManager = centralManager
    }
    
    
    open func connect(uuid: UUID) async -> Result<any PeripheralProtocol, CentralManagerTaskFailure> {
        switch await discover(uuid: uuid) {
        case .failure(let error):
            return .failure(.init(wrapping: error))
        case .success(let peripheral):
            switch await waitConnected(peripheral: peripheral) {
            case .failure(let error):
                return .failure(.init(wrapping: error))
            case .success:
                return .success(peripheral)
            }
        }
    }
    
    
    private func waitConnected(peripheral: any PeripheralProtocol) async -> Result<Void, CentralManagerTaskFailure> {
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

    
    public func discover(uuid: UUID) async -> Result<any PeripheralProtocol, CentralManagerTaskFailure> {
        switch await waitUntilPowerOn() {
        case .failure(let error):
            return .failure(error)
        case .success:
            return await waitDiscover(uuid: uuid)
        }
    }
    
    
    private func waitDiscover(uuid: UUID, timeout: TimeInterval) async -> Result<any PeripheralProtocol, CentralManagerTaskFailure> {
        let result = await Tasks.timeout(duration: timeout) {
            await self.waitDiscover(uuid: uuid)
        }
        switch result {
        case .failure(let error):
            return .failure(.init(wrapping: error))
        case .success(.failure(let error)):
            return .failure(error)
        case .success(.success(let peripheral)):
            return .success(peripheral)
        }
    }
    
    
    private func waitDiscover(uuid: UUID) async -> Result<any PeripheralProtocol, CentralManagerTaskFailure> {
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

    
    private func waitUntilPowerOn() async -> Result<Void, CentralManagerTaskFailure> {
        return await withCheckedContinuation { continuation in
            var cancellables = Set<AnyCancellable>()
            
            self.centralManager.didUpdateState
                .sink(receiveValue: { state in
                    defer { cancellables.removeAll() }
                    
                    switch state {
                    case .poweredOn:
                        continuation.resume(returning: .success(()))
                    case .poweredOff:
                        continuation.resume(returning: .failure(.init("Bluetooth is powered off")))
                    case .unauthorized:
                        continuation.resume(returning: .failure(.init("Bluetooth is unauthorized")))
                    case .unsupported:
                        continuation.resume(returning: .failure(.init("Bluetooth is unsupported")))
                    default:
                        break
                    }
                })
                .store(in: &cancellables)
        }
    }
}
