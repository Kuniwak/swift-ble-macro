import Foundation
import CoreBluetooth
import BLEInternal
import BLEInterpreter
import BLECommand


public struct WriteCommand: REPLCommandProtocol {
    public let name = "write-command"
    public var aliases: [String] = ["w", "wc"]
    public let abstract = "Write to a characteristic without a response"
    public let usage = "write-command <service-uuid> <characteristic-uuid> <hex>"
    private let interpreter: any InterpreterProtocol
    
    
    public init(interpreter: any InterpreterProtocol) {
        self.interpreter = interpreter
    }
    
    
    public func run<Args>(args: Args) async -> Result<Void, REPLError> where Args: RandomAccessCollection, Args.Element == String, Args.Index == Int {
        guard let serviceUUIDString = args.first else { return .failure(REPLError("service UUID is missing")) }
        guard let serviceUUID = UUIDs.from(toOptional: serviceUUIDString) else { return .failure(REPLError("invalid service UUID: \(serviceUUIDString)")) }
        guard args.count > 1 else { return .failure(REPLError("characteristic UUID is missing")) }
        guard let characteristicUUID = UUIDs.from(toOptional: args[1]) else { return .failure(REPLError("invalid characteristic UUID: \(args[1])")) }
        guard args.count > 2 else { return .failure(REPLError("hex is missing")) }
        
        switch HexEncoding.decode(hexString: args[2]) {
        case .failure(let error):
            return .failure(REPLError(wrapping: error))
        case .success(let decoded):
            let result = await interpreter.write(Write(
                serviceUUID: CBUUID(nsuuid: serviceUUID),
                characteristicUUID: CBUUID(nsuuid: characteristicUUID),
                value: decoded.data,
                writeType: .withoutResponse
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
