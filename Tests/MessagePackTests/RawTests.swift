import Foundation
import XCTest
@testable import MessagePack

class RawTests: XCTestCase {
    static var allTests = {
        return [
            ("testPack", testPack),
            ("testUnpack", testUnpack),
        ]
    }()

    // the payload is an already message packed value
    let payload = Data([0xA5, 0x68, 0x65, 0x6C, 0x6C, 0x6F])
    let packed = Data([0xA5, 0x68, 0x65, 0x6C, 0x6C, 0x6F])

    func testPack() {
        XCTAssertEqual(pack(.raw(payload)), packed)
    }

    func testUnpack() {
        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked?.value, .string("hello"))
        XCTAssertEqual(unpacked?.remainder.count, 0)
    }
}
