import ArgumentParser
import Foundation
import BLEMacro
import BLEMacroCompiler
import BLEInternal


struct MacroCompilation: ParsableCommand {
    @Argument(help: "Path to Macro XML Path")
    var macroXMLPath: String
    
    @Option(name: .long, help: "Logging severity (available: \(LogSeverity.allCases.map(\.rawValue).joined(separator: "/")))")
    var severity: String = LogSeverity.info.rawValue

    static let configuration = CommandConfiguration(
        commandName: "compile",
        abstract: "Compile BLE Macro XML"
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
    
    mutating func run() throws {
        guard let severity = LogSeverity(rawValue: severity.lowercased()) else {
            print(toStderr: "error: invalid severity: \(severity)")
            throw ExitCode(1)
        }

        var logger = Logger(severity: severity, writer: ConsoleLogWriter.stderr)
        
        do {
            let macroXML = try String(contentsOfFile: macroXMLPath, encoding: .utf8)
            let xml = try XMLDocument(xmlString: macroXML)
            let macro = try MacroXMLParser.parse(xml: xml).get()
            let commands = try Compiler(loggingBy: logger).compile(macro: macro).get()
            print(toStdout: commands.map(\.description).joined(separator: "\n"))
        } catch (let e) {
            logger.fault("error: \(e)")
            throw ExitCode(1)
        }
    }
}
