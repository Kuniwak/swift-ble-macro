import BLEInterpreter
import BLEInternal


public struct DescriptorDiscoveryCommand: REPLCommandProtocol {
    public let name = "discovery-descriptor"
    public let aliases = ["dd"]
    public let abstract = "Discover descriptors"
    public let usage = "discovery-descriptors"
    private let peripheralTasks: any PeripheralTasksProtocol
    
    
    public init(peripheralTasks: any PeripheralTasksProtocol) {
        self.peripheralTasks = peripheralTasks
    }
    
    
    public func run<Args>(args: Args) async -> Result<Void, REPLError> where Args : RandomAccessCollection, Args.Element == String, Args.Index == Int {
        switch await self.peripheralTasks.discoverDescriptors(searching: nil, forCharacteristicUUIDs: nil, inServiceUUIDs: nil) {
        case .failure(let error):
            return .failure(REPLError(wrapping: error))
        case .success(let descriptors):
            for descriptor in descriptors {
                print(toStdout: "\(descriptor.characteristic?.service?.uuid.uuidString ?? "-") \(descriptor.characteristic?.uuid.uuidString ?? "-") \(descriptor.uuid.uuidString)")
            }
            return .success(())
        }
    }
}
