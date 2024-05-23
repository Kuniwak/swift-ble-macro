import CoreBluetooth


public struct Environment {
    public var serviceEntries: [CBUUID: ServiceEntry]
    public var register: CommandResult?
    
    public init(services: [CBUUID: ServiceEntry], register: CommandResult?) {
        self.serviceEntries = services
        self.register = register
    }
}


public enum CommandResult: Equatable, Codable {
    case value(Data)
}
