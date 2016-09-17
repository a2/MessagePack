@testable import MessagePack
import XCTest

class BinaryTests: XCTestCase {
    let payload: MessagePack.Data = [0x00, 0x01, 0x02, 0x03, 0x04]
    let packed: MessagePack.Data = [0xc4, 0x05, 0x00, 0x01, 0x02, 0x03, 0x04]

    func testPack() {
        XCTAssertEqual(pack(.binary(payload)), packed)
    }

    func testUnpack() {
        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked, MessagePackValue.binary(payload))
    }

    func testPackBin16() {
        let value = MessagePack.Data(repeating: 0x00, count: 0xff)
        let expectedPacked = [0xc4, 0xff] + value
        XCTAssertEqual(pack(.binary(value)), expectedPacked)
    }

    func testUnpackBin16() {
        let data = [0xc4, 0xff] + MessagePack.Data(repeating: 0x00, count: 0xff)
        let value = MessagePack.Data(repeating: 0x00, count: 0xff)

        let unpacked = try? unpack(data)
        XCTAssertEqual(unpacked, MessagePackValue.binary(value))
    }

    func testPackBin32() {
        let value = MessagePack.Data(repeating: 0x00, count: 0x100)
        let expectedPacked = [0xc5, 0x01, 0x00] + value
        XCTAssertEqual(pack(.binary(value)), expectedPacked)
    }

    func testUnpackBin32() {
        let data =  [0xc5, 0x01, 0x00] + MessagePack.Data(repeating: 0x00, count: 0x100)
        let value = MessagePack.Data(repeating: 0x00, count: 0x100)

        let unpacked = try? unpack(data)
        XCTAssertEqual(unpacked, MessagePackValue.binary(value))
    }

    func testPackBin64() {
        let value = MessagePack.Data(repeating: 0x00, count: 0x1_0000)
        let expectedPacked = [0xc6, 0x00, 0x01, 0x00, 0x00] + value
        XCTAssertEqual(pack(.binary(value)), expectedPacked)
    }

    func testUnpackBin64() {
        let data = [0xc6, 0x00, 0x01, 0x00, 0x00] + MessagePack.Data(repeating: 0x00, count: 0x1_0000)
        let value = MessagePack.Data(repeating: 0x00, count: 0x1_0000)

        let unpacked = try? unpack(data)
        XCTAssertEqual(unpacked, MessagePackValue.binary(value))
    }

    func testUnpackInsufficientData() {
        let dataArray: [MessagePack.Data] = [
            // only type byte
            [0xc4], [0xc5], [0xc6],

            // type byte with no data
            [0xc4, 0x01],
            [0xc5, 0x00, 0x01],
            [0xc6, 0x00, 0x00, 0x00, 0x01],
        ]
        for data in dataArray {
            do {
                let _ = try unpack(data)
                XCTFail("Expected unpack to throw")
            } catch {
                XCTAssertEqual(error as? MessagePackError, .insufficientData)
            }
        }
    }

    func testUnpackFixstrWithCompatibility() {
        let data: MessagePack.Data = [0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x2c, 0x20, 0x77, 0x6f, 0x72, 0x6c, 0x64, 0x21]
        let packed: MessagePack.Data = [0xad] + data

        let unpacked = try? unpack(packed, compatibility: true)
        XCTAssertEqual(unpacked, MessagePackValue.binary(data))
    }

    func testUnpackStr8WithCompatibility() {
        let data = MessagePack.Data(repeating: 0x00, count: 0x20)
        let packed = [0xd9, 0x20] + data

        let unpacked = try? unpack(packed, compatibility: true)
        XCTAssertEqual(unpacked, MessagePackValue.binary(data))
    }

    func testUnpackStr16WithCompatibility() {
        let data = MessagePack.Data(repeating: 0x00, count: 0x1000)
        let packed = [0xda, 0x10, 0x00] + data

        let unpacked = try? unpack(packed, compatibility: true)
        XCTAssertEqual(unpacked, MessagePackValue.binary(data))
    }

    func testUnpackStr32WithCompatibility() {
        let data = MessagePack.Data(repeating: 0x00, count: 0x10000)
        let packed = [0xdb, 0x00, 0x01, 0x00, 0x00] + data

        let unpacked = try? unpack(packed, compatibility: true)
        XCTAssertEqual(unpacked, MessagePackValue.binary(data))
    }
}
