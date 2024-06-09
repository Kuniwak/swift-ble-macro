import BLEInternal


public struct HelpCommand: REPLCommandProtocol {
    public let name = "help"
    public var aliases: [String] = ["h", "?"]
    public let abstract = "Show help"
    public let usage = "help [<command>]"
    private let commands: [any REPLCommandProtocol]
    
    
    public init(commands: [any REPLCommandProtocol]) {
        self.commands = commands
    }
    
    
    public func run<Args>(args: Args) async -> Result<Void, REPLError> where Args: Collection, Args.Element == String {
        if let command = args.first {
            if let command = self.commands.first(where: { $0.name == command || $0.aliases.contains(command) }) {
                print(toStderr: command.abstract)
                print(toStderr: "Usage: \(command.usage)")
            } else {
                print(toStderr: "Unknown command: \(command)")
            }
        } else {
            for command in self.commands {
                let names = [command.name] + command.aliases
                print(toStderr: "\(names.joined(separator: ", "))\t\(command.abstract)")
            }
            print(toStderr: "q, quit\tQuit the REPL")
        }
        return .success(())
    }
    
    
    public static func appending(to commands: [any REPLCommandProtocol]) -> [any REPLCommandProtocol] {
        commands + [HelpCommand(commands: commands)]
    }
}
