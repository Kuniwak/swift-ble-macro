import BLEInternal
import BLEInterpreter


public class REPL {
    private let logger: any LoggerProtocol
    private let interpreter: any InterpreterProtocol
    private static let header = "(ble) "
    private let commandMap: [String: any REPLCommandProtocol]
    
    
    public static func defaultCommands(interactingInterpreter interpreter: any InterpreterProtocol, peripheralTasks: any PeripheralTasksProtocol) -> [any REPLCommandProtocol] {
        [
            WriteCommand(interpreter: interpreter),
            WriteDescriptorCommand(interpreter: interpreter),
            WriteRequestCommand(interpreter: interpreter),
            ReadCommand(interpreter: interpreter),
            ServiceDiscoveryCommand(peripheralTasks: peripheralTasks),
            CharacteristicDiscoveryCommand(peripheralTasks: peripheralTasks),
            DescriptorDiscoveryCommand(peripheralTasks: peripheralTasks),
        ]
    }
    

    public init(
        interpretingBy interpreter: any InterpreterProtocol,
        loggingBy logger: any LoggerProtocol,
        commands: [any REPLCommandProtocol]
    ) {
        self.logger = logger
        self.interpreter = interpreter
        self.commandMap = Dictionary(uniqueKeysWithValues: commands.flatMap { command in
            [(command.name, command)] + command.aliases.map { alias in (alias, command) }
        })
    }
    
    
    public func run() async {
        print(toStdout: REPL.header, newLine: false)
        while let line = readLine(strippingNewline: true) {
            let tokens = line.split(separator: " ").map(String.init(_:))
            let firstToken = tokens.first ?? ""
            
            guard !firstToken.isEmpty else {
                print(toStdout: REPL.header, newLine: false)
                continue
            }
            
            guard let command = commandMap[firstToken] else {
                print(toStdout: "unknown command: \(firstToken)")
                print(toStdout: REPL.header, newLine: false)
                continue
            }
            
            switch await command.run(args: Array(tokens.dropFirst())) {
            case .failure(let error):
                print(toStdout: "error: \(error.description)")
            case .success:
                break
            }
            print(toStdout: REPL.header, newLine: false)
        }
    }
}
