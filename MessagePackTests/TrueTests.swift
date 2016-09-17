@testable import MessagePack
import XCTest

class TrueTests: XCTestCase {
    let packed: MessagePack.Data = [0xc3]

    func testLiteralConversion() {
        let implicitValue: MessagePackValue = true
        XCTAssertEqual(implicitValue, MessagePackValue.bool(true))
    }

    func testPack() {
        XCTAssertEqual(pack(.bool(true)), packed)
    }

    func testUnpack() {
        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked, MessagePackValue.bool(true))
    }
}
