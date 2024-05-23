import Foundation
import CoreBluetooth
import BLEInternal
import BLEInterpreter
import BLECommand


public struct WriteDescriptorCommand: REPLCommandProtocol {
    public let name = "write-descriptor"
    public var aliases: [String] = ["wd"]
    public let abstract = "Write to a descriptor"
    public let usage = "write-descriptor-command <service-uuid> <characteristic-uuid> <descriptor-uuid> <hex>"
    private let interpreter: any InterpreterProtocol
    
    
    public init(interpreter: any InterpreterProtocol) {
        self.interpreter = interpreter
    }
    
    
    public func run<Args>(args: Args) async -> Result<Void, REPLError> where Args: RandomAccessCollection, Args.Element == String, Args.Index == Int {
        guard let serviceUUIDString = args.first else { return .failure(REPLError("service UUID is missing")) }
        guard let serviceUUID = UUIDs.from(toOptional: serviceUUIDString) else { return .failure(REPLError("invalid service UUID: \(serviceUUIDString)")) }
        guard args.count > 1 else { return .failure(REPLError("characteristic UUID is missing")) }
        guard let characteristicUUID = UUIDs.from(toOptional: args[1]) else { return .failure(REPLError("invalid characteristic UUID: \(args[1])")) }
        guard args.count > 2 else { return .failure(REPLError("descriptor UUID is missing")) }
        guard let descriptorUUID = UUIDs.from(toOptional: args[2]) else { return .failure(REPLError("invalid descriptor UUID: \(args[2])")) }
        guard args.count > 3 else { return .failure(REPLError("hex is missing")) }

        switch HexEncoding.decode(hexString: args[3]) {
        case .failure(let error):
            return .failure(REPLError(wrapping: error))
        case .success(let decoded):
            let result = await interpreter.writeDescriptor(WriteDescriptor(
                serviceUUID: CBUUID(nsuuid: serviceUUID),
                characteristicUUID: CBUUID(nsuuid: characteristicUUID),
                descriptorUUID: CBUUID(nsuuid: descriptorUUID),
                value: decoded.data
            ))
            switch result {
            case .failure(let error):
                return .failure(REPLError(wrapping: error))
            case .success:
                return .success(())
            }
        }
    }
}
