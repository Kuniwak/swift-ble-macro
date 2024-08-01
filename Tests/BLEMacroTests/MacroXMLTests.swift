import SwiftCheck
import XCTest
import BLEMacro
import BLEMacroStub
import Fuzi
import MirrorDiffKit


private struct IdentityError: Error, CustomStringConvertible {
    public let description: String
    
    
    public init(_ description: String) {
        self.description = description
    }
}


final class MacroXMLTests: XCTestCase {
    func testWriteAndParse() throws {
        property("Writing and parsing XML should be an identity") <- forAll { (macro: Macro) throws in
            var xmlString: TextOutputStream = ""
            MacroXMLWriter.write(macro.xml(), to: &xmlString, withIndent: 0)
            let xmlDoc = try XMLDocument(string: xmlString as! String)
            switch MacroXMLParser.parse(xml: xmlDoc) {
            case .failure(let error):
                return false <?> "\(error)"
            case .success(let parsed):
                if macro == parsed {
                    return true
                } else {
                    return false <?> diff(between: macro, and: parsed)
                }
            }
        }
    }
}
