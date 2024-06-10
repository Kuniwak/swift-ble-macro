import struct Foundation.UUID
import struct Foundation.Data
import struct Foundation.URL
import os
import Fuzi
import BLEMacro
import BLEMacroCompiler
import BLEInterpreter
import BLEInternal
import CoreBluetoothTestable
import Logger


public func run(macroXMLString: String, on peripheralUUID: UUID, loggingTo logDst: LogDestination = .console, withSeverity severity: LogSeverity = .info, _ readHandler: ((Data) -> Void)? = nil) async throws {
    let macroXML = try Fuzi.XMLDocument(string: macroXMLString, encoding: .utf8)
    try await run(macroXML: macroXML, on: peripheralUUID, loggingTo: logDst, withSeverity: severity, readHandler)
}


public func run(macroXMLURL: URL, on peripheralUUID: UUID, loggingTo logDst: LogDestination = .console, withSeverity severity: LogSeverity = .info, _ readHandler: ((Data) -> Void)? = nil) async throws {
    let macroXMLString = try String(contentsOf: macroXMLURL, encoding: .utf8)
    try await run(macroXMLString: macroXMLString, on: peripheralUUID, loggingTo: logDst, withSeverity: severity, readHandler)
}


private func run(macroXML: XMLDocument, on peripheralUUID: UUID, loggingTo logDst: LogDestination, withSeverity severity: LogSeverity, _ readHandler: ((Data) -> Void)?) async throws {
    let logger = Logger(severity: severity, writer: try logDst.buildLogWriter())
    
    let macro = try MacroXMLParser.parse(xml: macroXML).get()
    let commands = try Compiler(loggingBy: logger).compile(macro: macro).get()
    let central = CentralManager(loggingBy: logger)
    let centralManagerTasks = CentralManagerTasks(loggingBy: logger, centralManager: central)
    let peripheral = try await centralManagerTasks.connect(uuid: peripheralUUID).get()
    defer { central.cancelPeripheralConnection(peripheral) }

    let interpreter = Interpreter(onPeripheral: peripheral, loggingBy: logger, readHandler)
    try await interpreter.interpret(commands: commands).get()
}
