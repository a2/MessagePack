@testable import MessagePack
import XCTest

func map(_ count: Int) -> [MessagePackValue : MessagePackValue] {
    var dict = [MessagePackValue : MessagePackValue]()
    for i in 0..<count {
        dict[.int(numericCast(i))] = .nil
    }

    return dict
}

func payload(_ count: Int) -> MessagePack.Data {
    var data = MessagePack.Data()
    for i in 0..<count {
        data += pack(.int(numericCast(i))) + pack(.nil)
    }
    
    return data
}

func testPackMap(_ count: Int, prefix: MessagePack.Data) {
    let packed = pack(.map(map(count)))

    var generator = packed.makeIterator()
    for expectedByte in prefix {
        let byte = generator.next()!
        XCTAssertEqual(byte, expectedByte)
    }

    var keys = Set<Int>()
    for _ in 0..<count {
        let value = try! unpack(&generator)
        let key: Int = numericCast(value.integerValue!)

        XCTAssertFalse(keys.contains(key))
        keys.insert(key)

        let nilValue = try! unpack(&generator)
        XCTAssertEqual(nilValue, MessagePackValue.nil)
    }
    
    XCTAssertEqual(keys.count, count)
}

class MapTests: XCTestCase {
    func testLiteralConversion() {
        let implicitValue: MessagePackValue = ["c": "cookie"]
        XCTAssertEqual(implicitValue, MessagePackValue.map([.string("c"): .string("cookie")]))
    }

    func testPackFixmap() {
        let packed: MessagePack.Data = [0x81, 0xa1, 0x63, 0xa6, 0x63, 0x6f, 0x6f, 0x6b, 0x69, 0x65]
        XCTAssertEqual(pack(.map([.string("c"): .string("cookie")])), packed)
    }

    func testUnpackFixmap() {
        let packed: MessagePack.Data = [0x81, 0xa1, 0x63, 0xa6, 0x63, 0x6f, 0x6f, 0x6b, 0x69, 0x65]

        let unpacked = try? unpack(packed)
        XCTAssertEqual(unpacked, MessagePackValue.map([.string("c"): .string("cookie")]))
    }

    func testPackMap16() {
        testPackMap(16, prefix: [0xde, 0x00, 0x10])
    }

    func testUnpackMap16() {
        let unpacked = try? unpack([0xde, 0x00, 0x10] + payload(16))
        XCTAssertEqual(unpacked, MessagePackValue.map(map(16)))
    }

    func testPackMap32() {
        testPackMap(0x1_0000, prefix: [0xdf, 0x00, 0x01, 0x00, 0x00])
    }

    func testUnpackMap32() {
        let unpacked = try? unpack([0xdf, 0x00, 0x01, 0x00, 0x00] + payload(0x1_0000))
        XCTAssertEqual(unpacked, MessagePackValue.map(map(0x1_0000)))
    }
}
