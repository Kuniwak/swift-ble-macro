import Combine
import BLEModel


public class StubPeripheralsNewDiscoveryModel: PeripheralsNewDiscoveryModelProtocol {
    public let didDiscover: AnyPublisher<PeripheralDiscoveryEntry, Never>
    public let didDiscoverSubject: PassthroughSubject<PeripheralDiscoveryEntry, Never>
    
    
    public init() {
        let didDiscoverSubject = PassthroughSubject<PeripheralDiscoveryEntry, Never>()
        self.didDiscoverSubject = didDiscoverSubject
        self.didDiscover = didDiscoverSubject.eraseToAnyPublisher()
    }
    
    
    public func scan() {
    }
    
    
    public func stopScan() {
    }
}
