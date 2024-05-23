import Foundation
import ArgumentParser
import Combine
import CoreBluetooth
import CoreBluetoothTestable
import BLEInternal
import BLEInterpreter
import BLECommand


struct StartREPL: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "repl",
        abstract: "Run REPL"
    )
    
    @Option(name: .long, help: "Peripheral UUID")
    var uuid: String

    @Option(name: .long, help: "Logging severity (available: \(LogSeverity.allCases.map(\.rawValue).joined(separator: "/")))")
    var severity: String = LogSeverity.info.rawValue
    
    
    mutating func run() async throws {
        guard let severity = LogSeverity(rawValue: severity.lowercased()) else {
            fputs("error: invalid severity: \(severity)\n", stderr)
            throw ExitCode(1)
        }
        
        guard let uuid = UUID(uuidString: uuid) else {
            print(toStderr: "error: invalid UUID: \(uuid)")
            throw ExitCode(1)
        }

        let fileManager = FileManager.default
        let logURL = fileManager.temporaryDirectory.appending(path: "ble-repl.log", directoryHint: .notDirectory)
        print(toStderr: "log file: \(logURL.path())")
        
        do {
            if !fileManager.fileExists(atPath: logURL.path()) {
                guard fileManager.createFile(atPath: logURL.path(), contents: nil, attributes: nil) else {
                    print(toStderr: "error: failed to create log file")
                    throw ExitCode(1)
                }
            }
            let logger = Logger(severity: severity, writer: FileLogWriter(writeTo: try FileHandle(forWritingTo: logURL), encoding: .utf8))

            print(toStderr: "connecting...")
            
            let central = CentralManager(loggingBy: logger)
            let centralManagerTasks = BLEInterpreter.CentralManagerTasks(loggingBy: logger, centralManager: central)
            let peripheral = try await centralManagerTasks.connect(uuid: uuid).get()
            defer { central.cancelPeripheralConnection(peripheral) }
            let peripheralTasks = PeripheralTasks(peripheral: peripheral)

            print(toStderr: "connected")
            
            let interpreter = Interpreter(onPeripheral: peripheral, loggingBy: logger)
            let repl = REPL(
                interpretingBy: interpreter,
                loggingBy: logger,
                commands: HelpCommand.appending(to: REPL.defaultCommands(interactingInterpreter: interpreter, peripheralTasks: peripheralTasks))
            )
            await repl.run()
        } catch (let e) {
            print(toStderr: "error: \(e)")
            throw ExitCode(1)
        }
    }
}
