import Combine
import BLEModel


public class SpyPeripheralsNewDiscoveryModel: PeripheralsNewDiscoveryModelProtocol {
    public var didDiscover: AnyPublisher<PeripheralDiscoveryEntry, Never> { inherited.didDiscover }
    
    public var inherited: any PeripheralsNewDiscoveryModelProtocol
    public private(set) var callArgs = [CallArg]()
    
    
    public init(inheriting inherited: any PeripheralsNewDiscoveryModelProtocol = StubPeripheralsNewDiscoveryModel()) {
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
