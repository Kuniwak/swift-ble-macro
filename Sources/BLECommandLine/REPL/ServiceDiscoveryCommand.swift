import BLEInterpreter
import BLEInternal


public struct ServiceDiscoveryCommand: REPLCommandProtocol {
    public let name = "discovery-service"
    public let aliases = ["ds"]
    public let abstract = "Discover services"
    public let usage = "discovery-service"
    private let peripheralTasks: any PeripheralTasksProtocol
    
    
    public init(peripheralTasks: any PeripheralTasksProtocol) {
        self.peripheralTasks = peripheralTasks
    }
    
    
    public func run<Args>(args: Args) async -> Result<Void, REPLError> where Args : RandomAccessCollection, Args.Element == String, Args.Index == Int {
        switch await self.peripheralTasks.discoverServices(searching: nil) {
        case .failure(let error):
            return .failure(REPLError(wrapping: error))
        case .success(let services):
            for service in services {
                print(toStdout: service.uuid.uuidString)
            }
            return .success(())
        }
    }
}
