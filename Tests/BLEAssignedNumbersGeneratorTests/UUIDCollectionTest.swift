import XCTest
import BLEAssignedNumbersGenerator
import MirrorDiffKit


final class UUIDCollectionTest: XCTestCase {
    func testParse() {
        let yamlString = """
uuids:
 - uuid: 0x1234
   name: Example
   id: com.example
"""
        
        let url = URL(string: "file:///path/to/example.yaml")!
        let result = UUIDCollection.parse(fromYAML: yamlString, atURL: url)
        let expected = UUIDCollection(url: url, entries: [
            UUIDCollectionEntry(name: "Example", id: "com.example", uuid: (0x12, 0x34)),
        ])
        
        switch result {
        case .failure(let e):
            XCTFail("\(e)")
        case .success(let actual):
            XCTAssertEqual(expected, actual, diff(between: expected, and: actual))
        }
    }
}
