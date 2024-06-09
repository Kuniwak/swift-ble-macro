import Foundation
import ArgumentParser
import BLEInternal
import BLEMacro
import BLEMacroCompiler
import BLEInterpreter
import CoreBluetoothTestable


struct MacroExecution: AsyncParsableCommand {
    @Argument(help: "Path to Macro XML Path")
    var macroXMLPath: String
    
    @Option(name: .long, help: "Peripheral UUID")
    var uuid: String
    
    @Option(name: .long, help: "Logging severity (available: \(LogSeverity.allCases.map(\.rawValue).joined(separator: "/")))")
    var severity: String = LogSeverity.info.rawValue

    
    static let configuration = CommandConfiguration(
        commandName: "run",
        abstract: "Execute BLE Macro XML"
    )
    
    
    func validate() throws {
        var isDirectory = ObjCBool(false)
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: macroXMLPath, isDirectory: &isDirectory) else {
            print(toStderr: "error: no such file: \(macroXMLPath)")
            throw ExitCode(1)
        }
        
        guard fileManager.isReadableFile(atPath: macroXMLPath) else {
            print(toStderr: "error: cannot read: \(macroXMLPath)")
            throw ExitCode(1)
        }
    }
    
    
    mutating func run() async throws {
        guard let severity = LogSeverity(rawValue: severity.lowercased()) else {
            print(toStderr: "error: invalid severity: \(severity)")
            throw ExitCode(1)
        }
        
        guard let uuid = UUID(uuidString: uuid) else {
            print(toStderr: "error: invalid UUID: \(uuid)")
            throw ExitCode(1)
        }

        let logger = Logger(severity: severity, writer: ConsoleLogWriter.stderr)
        
        do {
            let macroXML = try String(contentsOfFile: macroXMLPath, encoding: .utf8)
            logger.info("macro loaded")

            let xml = try XMLDocument(xmlString: macroXML)
            let macro = try MacroXMLParser.parse(xml: xml).get()
            
            logger.info("macro parse succeeded")
            
            let commands = try Compiler(loggingBy: logger).compile(macro: macro).get()
            
            logger.info("compilation succeeded")
            
            let central = CentralManager(loggingBy: logger)
            let peripheralTasks = BLEInterpreter.CentralManagerTasks(loggingBy: logger, centralManager: central)
            
            logger.info("connecting...")

            let peripheral = try await peripheralTasks.connect(uuid: uuid).get()
            defer { central.cancelPeripheralConnection(peripheral) }

            logger.info("connected")
            
            let interpreter = Interpreter(onPeripheral: peripheral, loggingBy: logger) { data in
                print(toStdout: HexEncoding.lower.encode(data: data))
            }
            _ = try await interpreter.interpret(commands: commands).get()
            logger.info("done")
        } catch (let e) {
            logger.fault("error: \(e)")
            throw ExitCode(1)
        }
    }
}
