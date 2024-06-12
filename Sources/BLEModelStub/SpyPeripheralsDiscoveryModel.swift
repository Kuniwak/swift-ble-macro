import Combine
import BLEModel


public class SpyPeripheralsDiscoveryModel: PeripheralsDiscoveryModelProtocol {
    public var state: PeripheralsDiscoveryModelState { inherited.state }
    public var stateDidUpdate: AnyPublisher<PeripheralsDiscoveryModelState, Never> {
        inherited.stateDidUpdate
    }
    
    
    public var inherited: any PeripheralsDiscoveryModelProtocol
    public private(set) var callArgs = [CallArg]()
    
    
    public init(inheriting inherited: any PeripheralsDiscoveryModelProtocol = StubPeripheralsDiscoveryModel()) {
        self.inherited = inherited
    }
    
    
    public func scan() {
        callArgs.append(.scan)
        inherited.scan()
    }
    
    
    public func stopScan() {
        callArgs.append(.stopScan)
        inherited.stopScan()
    }
    
    
    public enum CallArg: Equatable {
        case scan
        case stopScan
    }
}
