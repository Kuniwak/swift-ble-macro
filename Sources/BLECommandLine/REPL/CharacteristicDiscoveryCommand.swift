import BLEInterpreter
import BLEInternal


public struct CharacteristicDiscoveryCommand: REPLCommandProtocol {
    public let name = "discovery-characteristics"
    public let aliases = ["dc"]
    public let abstract = "Discover characteristics"
    public let usage = "discovery-characteristics"
    private let peripheralTasks: any PeripheralTasksProtocol
    
    
    public init(peripheralTasks: any PeripheralTasksProtocol) {
        self.peripheralTasks = peripheralTasks
    }
    
    
    public func run<Args>(args: Args) async -> Result<Void, REPLError> where Args : RandomAccessCollection, Args.Element == String, Args.Index == Int {
        switch await self.peripheralTasks.discoverCharacteristics(searching: nil, forServiceUUIDs: nil) {
        case .failure(let error):
            return .failure(REPLError(wrapping: error))
        case .success(let characteristics):
            for characteristic in characteristics {
                var properties = [String]()
                if characteristic.properties.contains(.broadcast) {
                    properties.append("broadcast")
                }
                if characteristic.properties.contains(.read) {
                    properties.append("read")
                }
                if characteristic.properties.contains(.write) {
                    properties.append("write")
                }
                if characteristic.properties.contains(.writeWithoutResponse) {
                    properties.append("writeWithoutResponse")
                }
                if characteristic.properties.contains(.write) {
                    properties.append("write")
                }
                if characteristic.properties.contains(.notify) {
                    properties.append("notify")
                }
                if characteristic.properties.contains(.indicate) {
                    properties.append("indicate")
                }
                if characteristic.properties.contains(.authenticatedSignedWrites) {
                    properties.append("authenticatedSignedWrites")
                }
                if characteristic.properties.contains(.extendedProperties) {
                    properties.append("extendedProperties")
                }
                print(toStdout: "\(characteristic.service?.uuid.uuidString ?? "-") \(characteristic.uuid.uuidString) \(properties.joined(separator: "/"))")
            }
            return .success(())
        }
    }
}
