import XCTest
import BLEInternal


final class TasksTests: XCTestCase {
    func testRace() async {
        let result = await Tasks.race2({ () async -> Int in
            return 1
        }, { () async -> Int in
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            return 2
        })
        XCTAssertEqual(result, 1)
    }
    
    
    func testTimeout_noTimeout() async {
        let result = await Tasks.timeout(duration: 1_000_000_000) {}
        
        switch result {
        case .failure:
            XCTFail("Expected resolved")
        case .success:
            break
        }
    }
    
    
    func testTimeout_timeout() async {
        let result = await Tasks.timeout(duration: 0) {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            return ()
        }
        
        switch result {
        case .failure:
            break
        case .success:
            XCTFail("Expected timeout")
        }
    }
}
