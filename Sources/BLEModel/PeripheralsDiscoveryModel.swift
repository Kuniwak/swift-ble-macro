import Combine
import CoreBluetooth
import CoreBluetoothTestable
import Logger


public struct PeripheralDiscoveryEntry {
    public let peripheral: AnyPeripheral
    public let advertisementData: [String: Any]
    public let rssi: NSNumber
    
    
    public init(peripheral: AnyPeripheral, advertisementData: [String : Any], rssi: NSNumber) {
        self.peripheral = peripheral
        self.advertisementData = advertisementData
        self.rssi = rssi
    }
    
    
    public var uuid: UUID {
        return peripheral.identifier
    }
}


extension PeripheralDiscoveryEntry: CustomStringConvertible {
    public var description: String {
        "[\(advertisementData[CBAdvertisementDataLocalNameKey] ?? "(no name)"), \(peripheral.identifier.uuidString)]"
    }
}


public enum PeripheralsDiscoveryModelState {
    case notReady
    case awaitingReady
    case ready
    case discovering([UUID: PeripheralDiscoveryEntry])
    case discovered([UUID: PeripheralDiscoveryEntry])
    
    
    public var entries: [UUID: PeripheralDiscoveryEntry] {
        switch self {
        case .notReady, .awaitingReady, .ready:
            return [:]
        case .discovering(let entries):
            return entries
        case .discovered(let entries):
            return entries
        }
    }
    
    
    public var isDiscovering: Bool {
        switch self {
        case .discovering:
            return true
        case .awaitingReady, .discovered, .notReady, .ready:
            return false
        }
    }
}


extension PeripheralsDiscoveryModelState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .notReady:
            return "notReady"
        case .awaitingReady:
            return "awaitingReady"
        case .ready:
            return "ready"
        case .discovering(let entries):
            return "discovering[\(entries.count) entries]"
        case .discovered(let entries):
            return "discovered[\(entries.count) entries]"
        }
    }
}


public protocol PeripheralsDiscoveryModelProtocol {
    var state: PeripheralsDiscoveryModelState { get }
    var stateDidUpdate: AnyPublisher<PeripheralsDiscoveryModelState, Never> { get }
    func scan()
    func stopScan()
}


public class PeripheralsDiscoveryModel: PeripheralsDiscoveryModelProtocol {
    private let stateDidUpdateSubject: CurrentValueSubject<PeripheralsDiscoveryModelState, Never>
    public var state: PeripheralsDiscoveryModelState { stateDidUpdateSubject.value }
    public let stateDidUpdate: AnyPublisher<PeripheralsDiscoveryModelState, Never>
    private let serviceUUIDs: [CBUUID]?
    
    private let centralManager: CentralManagerProtocol
    private var cancellables = Set<AnyCancellable>()
    
    
    public init(observingCentral centralManager: any CentralManagerProtocol, searching serviceUUIDs: [CBUUID]?) {
        let stateDidUpdateSubject = CurrentValueSubject<PeripheralsDiscoveryModelState, Never>(.notReady)
        self.stateDidUpdateSubject = stateDidUpdateSubject
        self.stateDidUpdate = stateDidUpdateSubject.eraseToAnyPublisher()
        
        self.centralManager = centralManager
        self.serviceUUIDs = serviceUUIDs
        
        centralManager.didUpdateState
            .sink { [weak self] state in
                guard let self else { return }
                
                switch (state, self.state) {
                case (.poweredOn, .notReady):
                    self.stateDidUpdateSubject.value = .ready
                case (.poweredOn, .awaitingReady), (.poweredOn, .discovered):
                    self.centralManager.scanForPeripherals(withServices: nil)
                case (.poweredOff, let state):
                    self.stateDidUpdateSubject.value = .discovered(state.entries)
                case (_, _):
                    self.stateDidUpdateSubject.value = .notReady
                }
            }
            .store(in: &cancellables)
        
        centralManager.didDiscoverPeripheral
            .sink { [weak self] resp in
                guard let self else { return }
                
                var newEntries = self.state.entries
                newEntries[resp.peripheral.identifier] = PeripheralDiscoveryEntry(peripheral: resp.peripheral.asAny(), advertisementData: resp.advertisementData, rssi: resp.rssi)
                self.stateDidUpdateSubject.value = .discovering(newEntries)
            }
            .store(in: &cancellables)
    }
    
    
    public func scan() {
        switch self.state {
        case .awaitingReady, .discovering:
            return
        case .notReady:
            self.stateDidUpdateSubject.value = .awaitingReady
        case .ready, .discovered:
            self.centralManager.scanForPeripherals(withServices: serviceUUIDs)
        }
    }
    
    
    public func stopScan() {
        guard state.isDiscovering else { return }
        centralManager.stopScan()
        stateDidUpdateSubject.value = .discovered(self.stateDidUpdateSubject.value.entries)
    }
}


public class PeripheralsDiscoveryModelLogger: Subscriber, Cancellable {
    public typealias Input = PeripheralsDiscoveryModelState
    public typealias Failure = Never
    
    public let combineIdentifier = CombineIdentifier()
    private let logger: any LoggerProtocol
    private var cancellables = Set<AnyCancellable>()

    public init(loggingBy logger: any LoggerProtocol) {
        self.logger = logger
    }
    
    public func receive(subscription: any Subscription) {
        subscription.store(in: &cancellables)
        subscription.request(.unlimited)
    }
    
    public func receive(_ input: PeripheralsDiscoveryModelState) -> Subscribers.Demand {
        logger.debug(input.description)
        return .unlimited
    }
    
    public func receive(completion: Subscribers.Completion<Never>) {}
    
    public func cancel() {
        cancellables.removeAll()
    }
}


extension CBManagerState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .poweredOff:
            return "poweredOff"
        case .poweredOn:
            return "poweredOn"
        case .resetting:
            return "resetting"
        case .unauthorized:
            return "unauthorized"
        case .unsupported:
            return "unsupporeted"
        case .unknown:
            return "unknown"
        default:
            return "\(self)"
        }
    }
}
