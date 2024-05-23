import XCTest
import MirrorDiffKit
import BLEMacro
import BLEAssignedNumbers


final class MacroXMLParserTests: XCTestCase {
    func testParse() throws {
        let url = Bundle.module.url(forResource: "Fixtures/example", withExtension: ".xml")!
        let xml = try XMLDocument(contentsOf: url)
        
        switch MacroXMLParser.parse(xml: xml) {
        case .failure(let error):
            XCTFail("\(error)")
        case .success(let actual):
            let expected = Macro(
                name: "Example Macro",
                icon: .play,
                assertServices: [
                    .init(
                        description: "Example Service",
                        uuid: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                        characteristicAsserts: [
                            .init(
                                description: "Write",
                                uuid: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
                                properties: [
                                    .init(name: .write, requirement: .mandatory),
                                ]
                            ),
                            .init(
                                description: "Notification",
                                uuid: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
                                properties: [
                                    .init(name: .notify, requirement: .mandatory),
                                ],
                                assertCCCD: AssertCCCD()
                            ),
                        ]
                    )
                ],
                operations: [
                    .writeDescriptor(.init(
                        description: "Enable Notifications",
                        uuid: AssignedNumbers.Descriptors.clientCharacteristicConfiguration.uuid(),
                        serviceUUID: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                        characteristicUUID: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
                        value: .data(
                            data: Data([UInt8(0x01), UInt8(0x00)]),
                            encoding: .lower
                        )
                    )),
                    .write(.init(
                        description: "Write 0x1234",
                        serviceUUID: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                        characteristicUUID: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
                        type: .writeRequest,
                        value: .data(data: Data([0x12, 0x34]), encoding: .lower)
                    )),
                    .waitForNotification(.init(
                        description: "Wait for Notification",
                        serviceUUID: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                        characteristicUUID: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!
                    ))
                ]
            )
            XCTAssertEqual(expected, actual, diff(between: expected, and: actual))
        }
    }
}
