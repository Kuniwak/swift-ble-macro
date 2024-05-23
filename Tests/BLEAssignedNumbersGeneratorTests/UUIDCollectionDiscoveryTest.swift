import XCTest
import MirrorDiffKit
import BLEAssignedNumbersGenerator


final class UUIDCollectionDiscoveryTest: XCTestCase {
    func testDiscover() {
        var repoRoot = Bundle.module.resourceURL!
        repoRoot.append(path: "Fixtures/bluetooth-SIG-public", directoryHint: .isDirectory)
        
        let discovery = UUIDCollectionDiscovery(fileManager: .default)
        switch discovery.discover(fromRepository: repoRoot) {
        case .failure(let error):
            XCTFail("\(error)")
        case .success(let actual):
            let expected = [
                URL(string: "assigned_numbers/uuids/example.yaml", relativeTo: repoRoot)!,
            ]
            XCTAssertEqual(expected, actual, diff(between: expected, and: actual))
        }
    }
}
