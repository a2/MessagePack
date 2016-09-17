@testable import MessagePack
import XCTest

class ArrayTests: XCTestCase {
    func testLiteralConversion() {
        let implicitValue: MessagePackValue = [0, 1, 2, 3, 4]
        let payload: [MessagePackValue] = [.uInt(0), .uInt(1), .uInt(2), .uInt(3), .uInt(4)]
        XCTAssertEqual(implicitValue, MessagePackValue.array(payload))
    }

    func testPackFixarray() {
        let value: [MessagePackValue] = [.uInt(0), .uInt(1), .uInt(2), .uInt(3), .uInt(4)]
        let packed: MessagePack.Data = [0x95, 0x00, 0x01, 0x02, 0x03, 0x04]
        XCTAssertEqual(pack(.array(value)), packed)
    }

    func testUnpackFixarray() {
        let packed: MessagePack.Data = [0x95, 0x00, 0x01, 0x02, 0x03, 0x04]
        let value: [MessagePackValue] = [.uInt(0), .uInt(1), .uInt(2), .uInt(3), .uInt(4)]

        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked, MessagePackValue.array(value))
    }

    func testPackArray16() {
        let value = [MessagePackValue](repeating: nil, count: 16)
        let packed = [0xdc, 0x00, 0x10] + MessagePack.Data(repeating: 0xc0, count: 16)
        XCTAssertEqual(pack(.array(value)), packed)
    }

    func testUnpackArray16() {
        let packed = [0xdc, 0x00, 0x10] + MessagePack.Data(repeating: 0xc0, count: 16)
        let value = [MessagePackValue](repeating: nil, count: 16)

        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked, MessagePackValue.array(value))
    }

    func testPackArray32() {
        let value = [MessagePackValue](repeating: nil, count: 0x1_0000)
        let packed = [0xdd, 0x00, 0x01, 0x00, 0x00] + MessagePack.Data(repeating: 0xc0, count: 0x1_0000)
        XCTAssertEqual(pack(.array(value)), packed)
    }

    func testUnpackArray32() {
        let packed = [0xdd, 0x00, 0x01, 0x00, 0x00] + MessagePack.Data(repeating: 0xc0, count: 0x1_0000)
        let value = [MessagePackValue](repeating: nil, count: 0x1_0000)

        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked, MessagePackValue.array(value))
    }
}
