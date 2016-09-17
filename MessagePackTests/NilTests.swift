@testable import MessagePack
import XCTest

class NilTests: XCTestCase {
    let packed: MessagePack.Data = [0xc0]

    func testLiteralConversion() {
        let implicitValue: MessagePackValue = nil
        XCTAssertEqual(implicitValue, MessagePackValue.nil)
    }

    func testPack() {
        XCTAssertEqual(pack(.nil), packed)
    }

    func testUnpack() {
        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked, MessagePackValue.nil)
    }
}
