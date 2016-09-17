@testable import MessagePack
import XCTest

func string(_ length: Int, repeatedValue: String = "*") -> String {
    var str = ""
    str.reserveCapacity(length * repeatedValue.characters.count)

    for _ in 0..<length {
        str.append(repeatedValue)
    }

    return str
}

func data(_ string: String) -> Foundation.Data {
    return Data(string.utf8)
}

class StringTests: XCTestCase {
    func testLiteralConversion() {
        var implicitValue: MessagePackValue

        implicitValue = "Hello, world!"
        XCTAssertEqual(implicitValue, MessagePackValue.string("Hello, world!"))

        implicitValue = MessagePackValue(extendedGraphemeClusterLiteral: "Hello, world!")
        XCTAssertEqual(implicitValue, MessagePackValue.string("Hello, world!"))

        implicitValue = MessagePackValue(unicodeScalarLiteral: "Hello, world!")
        XCTAssertEqual(implicitValue, MessagePackValue.string("Hello, world!"))
    }

    func testPackFixstr() {
        let packed: MessagePack.Data = [0xad, 0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x2c, 0x20, 0x77, 0x6f, 0x72, 0x6c, 0x64, 0x21]
        XCTAssertEqual(pack(.string("Hello, world!")), packed)
    }

    func testUnpackFixstr() {
        let packed: MessagePack.Data = [0xad, 0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x2c, 0x20, 0x77, 0x6f, 0x72, 0x6c, 0x64, 0x21]

        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked, MessagePackValue.string("Hello, world!"))
    }

    func testPackStr8() {
        let str = string(0x20)
        XCTAssertEqual(pack(.string(str)), [0xd9, 0x20] + data(str))
    }

    func testUnpackStr8() {
        let str = string(0x20)
        let packed = [0xd9, 0x20] + data(str)

        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked, MessagePackValue.string(str))
    }

    func testPackStr16() {
        let str = string(0x1000)
        XCTAssertEqual(pack(.string(str)), [0xda, 0x10, 0x00] + data(str))
    }

    func testUnpackStr16() {
        let str = string(0x1000)
        let packed = [0xda, 0x10, 0x00] + data(str)

        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked, MessagePackValue.string(str))
    }

    func testPackStr32() {
        let str = string(0x10000)
        XCTAssertEqual(pack(.string(str)), [0xdb, 0x00, 0x01, 0x00, 0x00] + data(str))
    }

    func testUnpackStr32() {
        let str = string(0x10000)
        let packed = [0xdb, 0x00, 0x01, 0x00, 0x00] + data(str)

        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked, MessagePackValue.string(str))
    }
}
