import Combine
import CoreBluetooth
import CoreBluetoothTestable
import Logger


public protocol PeripheralsNewDiscoveryModelProtocol {
    var didDiscover: AnyPublisher<PeripheralDiscoveryEntry, Never> { get }
    func scan()
    func stopScan()
}


public class PeripheralsNewDiscoverModel: PeripheralsNewDiscoveryModelProtocol {
    private let didDiscoverSubject: PassthroughSubject<PeripheralDiscoveryEntry, Never>
    public let didDiscover: AnyPublisher<PeripheralDiscoveryEntry, Never>
    
    private var found = [UUID: PeripheralDiscoveryEntry]()
    private var cancellables = Set<AnyCancellable>()
    
    private let discoveryModel: any PeripheralsDiscoveryModelProtocol
    
    
    public init(observing discoveryModel: any PeripheralsDiscoveryModelProtocol) {
        let didDiscoverSubject = PassthroughSubject<PeripheralDiscoveryEntry, Never>()
        self.didDiscoverSubject = didDiscoverSubject
        self.didDiscover = didDiscoverSubject.eraseToAnyPublisher()
        
        self.discoveryModel = discoveryModel
        
        self.discoveryModel.stateDidUpdate
            .sink(receiveValue: { [weak self] state in
                guard let self else { return }
                
                let newUUIDs = Set(state.entries.keys).subtracting(self.found.keys)
                for newUUID in newUUIDs {
                    self.didDiscoverSubject.send(state.entries[newUUID]!)
                }
                self.found = state.entries
            })
            .store(in: &cancellables)
    }
    
    
    public func scan() {
        self.discoveryModel.scan()
    }
    
    
    public func stopScan() {
        self.discoveryModel.stopScan()
    }
}
