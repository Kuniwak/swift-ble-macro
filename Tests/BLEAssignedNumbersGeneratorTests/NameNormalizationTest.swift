import XCTest
import BLEAssignedNumbersGenerator


final class NameNormalizationTest: XCTestCase {
    struct TestCase {
        let description: String
        let line: UInt
        let words: [String]
        let expected: String
    }
    
    func testLowerCamelCase() {
        let testCases: [TestCase] = [
            .init(description: "empty", line: #line, words: [], expected: ""),
            .init(description: "single word", line: #line, words: ["foo"], expected: "foo"),
            .init(description: "several words", line: #line, words: ["foo", "bar"], expected: "fooBar"),
        ]
        
        for testCase in testCases {
            let actual = NameNormalization.lowerCamelCase(words: testCase.words)
            XCTAssertEqual(testCase.expected, actual, line: testCase.line)
        }
    }
    
    func testUpperCamelCase() {
        let testCases: [TestCase] = [
            .init(description: "empty", line: #line, words: [], expected: ""),
            .init(description: "single word", line: #line, words: ["foo"], expected: "Foo"),
            .init(description: "several words", line: #line, words: ["foo", "bar"], expected: "FooBar"),
        ]
        
        for testCase in testCases {
            let actual = NameNormalization.upperCamelCase(words: testCase.words)
            XCTAssertEqual(testCase.expected, actual, line: testCase.line)
        }
    }
}
