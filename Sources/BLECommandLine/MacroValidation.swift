import Foundation
import ArgumentParser
import BLEMacro
import BLEInternal


struct MacroValidation: ParsableCommand {
    @Argument(help: "Path to BLE Macro XML")
    var macroXMLPath: String

    static let configuration = CommandConfiguration(
        commandName: "validate",
        abstract: "Validate the specified Macro XML"
    )
    
    func validate() throws {
        let fileManager = FileManager.default
        
        var isDirectory = ObjCBool(false)
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
        do {
            let macroXML = try String(contentsOfFile: macroXMLPath, encoding: .utf8)
            let xml = try XMLDocument(xmlString: macroXML)
            _ = try MacroXMLParser.parse(xml: xml).get()
        } catch (let e) {
            print(toStderr: "error: \(e)")
            throw ExitCode(1)
        }
    }
}
