import Foundation
import CoreBluetooth
import BLEInternal
import BLEInterpreter
import BLECommand


public struct ReadCommand: REPLCommandProtocol {
    public let name = "read"
    public var aliases: [String] = ["r"]
    public let abstract = "Read from a characteristic"
    public let usage = "read <service-uuid> <characteristic-uuid>"
    private let interpreter: any InterpreterProtocol
    
    
    public init(interpreter: any InterpreterProtocol) {
        self.interpreter = interpreter
    }
    
    
    public func run<Args>(args: Args) async -> Result<Void, REPLError> where Args: RandomAccessCollection, Args.Element == String, Args.Index == Int {
        guard let serviceUUIDString = args.first else { return .failure(REPLError("service UUID is missing")) }
        guard let serviceUUID = UUIDs.from(toOptional: serviceUUIDString) else { return .failure(REPLError("invalid service UUID: \(serviceUUIDString)")) }
        guard args.count > 1 else { return .failure(REPLError("characteristic UUID is missing")) }
        guard let characteristicUUID = UUIDs.from(toOptional: args[1]) else { return .failure(REPLError("invalid characteristic UUID: \(args[1])")) }

        let result = await self.interpreter.read(Read(
            serviceUUID: CBUUID(nsuuid: serviceUUID),
            characteristicUUID: CBUUID(nsuuid: characteristicUUID)
        ))
        switch result {
        case .failure(let error):
            return .failure(REPLError(wrapping: error))
        case .success:
            switch interpreter.environment.register! {
            case .value(let data):
                print(toStdout: HexEncoding.lower.encode(data: data))
            }
            return .success(())
        }
    }
}
