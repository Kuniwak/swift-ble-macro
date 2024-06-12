import Combine
import BLEModel


public class StubPeripheralsDiscoveryModel: PeripheralsDiscoveryModelProtocol {
    public var state: PeripheralsDiscoveryModelState {
        stateDidUpdateSubject.value
    }
    public let stateDidUpdate: AnyPublisher<PeripheralsDiscoveryModelState, Never>
    public let stateDidUpdateSubject: CurrentValueSubject<PeripheralsDiscoveryModelState, Never>
    
    
    public init(state: PeripheralsDiscoveryModelState = .notReady) {
        let stateDidUpdateSubject = CurrentValueSubject<PeripheralsDiscoveryModelState, Never>(state)
        self.stateDidUpdateSubject = stateDidUpdateSubject
        self.stateDidUpdate = stateDidUpdateSubject.eraseToAnyPublisher()
    }
    
    
    public func scan() {
    }
    
    
    public func stopScan() {
    }
}
