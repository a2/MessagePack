@testable import MessagePack
import XCTest

class ConvenienceInitializersTests: XCTestCase {
    func testNil() {
        XCTAssertEqual(MessagePackValue(), MessagePackValue.Nil)
    }

    func testBool() {
        XCTAssertEqual(MessagePackValue(true), MessagePackValue.Bool(true))
        XCTAssertEqual(MessagePackValue(false), MessagePackValue.Bool(false))
        XCTAssertEqual(Bool(MessagePackValue(true)), true)
        XCTAssertEqual(Bool(MessagePackValue(false)), false)
    }

    func testUInt() {
        XCTAssertEqual(MessagePackValue(0 as UInt), MessagePackValue.UInt(0))
        XCTAssertEqual(MessagePackValue(0xff as UInt8), MessagePackValue.UInt(0xff))
        XCTAssertEqual(MessagePackValue(0xffff as UInt16), MessagePackValue.UInt(0xffff))
        XCTAssertEqual(MessagePackValue(0xffff_ffff as UInt32), MessagePackValue.UInt(0xffff_ffff))
        XCTAssertEqual(MessagePackValue(0xffff_ffff_ffff_ffff as UInt64), MessagePackValue.UInt(0xffff_ffff_ffff_ffff))
        
        XCTAssertEqual(UInt(MessagePackValue(0 as UInt)), UInt(0))
        XCTAssertEqual(UInt8(MessagePackValue(0xff as UInt8)), UInt8(0xff))
        XCTAssertEqual(UInt16(MessagePackValue(0xffff as UInt16)), UInt16(0xffff))
        XCTAssertEqual(UInt32(MessagePackValue(0xffff_ffff as UInt32)), UInt32(0xffff_ffff))
        XCTAssertEqual(UInt64(MessagePackValue(0xffff_ffff_ffff as UInt64)), UInt64(0xffff_ffff_ffff))
    }

    func testInt() {
        XCTAssertEqual(MessagePackValue(-1 as Int), MessagePackValue.Int(-1))
        XCTAssertEqual(MessagePackValue(-0x7f as Int8), MessagePackValue.Int(-0x7f))
        XCTAssertEqual(MessagePackValue(-0x7fff as Int16), MessagePackValue.Int(-0x7fff))
        XCTAssertEqual(MessagePackValue(-0x7fff_ffff as Int32), MessagePackValue.Int(-0x7fff_ffff))
        XCTAssertEqual(MessagePackValue(-0x7fff_ffff_ffff_ffff as Int64), MessagePackValue.Int(-0x7fff_ffff_ffff_ffff))
        
        XCTAssertEqual(Int(MessagePackValue(-1 as Int)), Int(-1))
        XCTAssertEqual(Int8(MessagePackValue(-0x7f as Int8)), Int8(-0x7f))
        XCTAssertEqual(Int16(MessagePackValue(-0x7fff as Int16)), Int16(-0x7fff))
        XCTAssertEqual(Int32(MessagePackValue(-0x7fff_ffff as Int32)), Int32(-0x7fff_ffff))
        XCTAssertEqual(Int64(MessagePackValue(-0x7fff_ffff_ffff_ffff as Int64)), Int64(-0x7fff_ffff_ffff_ffff))
    }

    func testFloat() {
        XCTAssertEqual(MessagePackValue(0 as Float), MessagePackValue.Float(0))
        XCTAssertEqual(MessagePackValue(1.618 as Float), MessagePackValue.Float(1.618))
        XCTAssertEqual(MessagePackValue(3.14 as Float), MessagePackValue.Float(3.14))
        XCTAssertEqual(Float(MessagePackValue.Float(3.14)), Float(3.14))
    }

    func testDouble() {
        XCTAssertEqual(MessagePackValue(0 as Double), MessagePackValue.Double(0))
        XCTAssertEqual(MessagePackValue(1.618 as Double), MessagePackValue.Double(1.618))
        XCTAssertEqual(MessagePackValue(3.14 as Double), MessagePackValue.Double(3.14))
        XCTAssertEqual(Double(MessagePackValue.Double(3.14)), Double(3.14))
    }

    func testString() {
        XCTAssertEqual(MessagePackValue("Hello, world!"), MessagePackValue.String("Hello, world!"))
        XCTAssertEqual(String(MessagePackValue("Hello, World")), "Hello, World")
    }


    func testArray() {
        XCTAssertEqual(MessagePackValue([.UInt(0), .UInt(1), .UInt(2), .UInt(3), .UInt(4)]), MessagePackValue.Array([.UInt(0), .UInt(1), .UInt(2), .UInt(3), .UInt(4)]))
    }

    func testMap() {
        XCTAssertEqual(MessagePackValue([.String("c"): .String("cookie")]), MessagePackValue.Map([.String("c"): .String("cookie")]))
    }

    func testBinary() {
        let data: Data = [0x00, 0x01, 0x02, 0x03, 0x04]
        XCTAssertEqual(MessagePackValue(data), MessagePackValue.Binary([0x00, 0x01, 0x02, 0x03, 0x04]))
        XCTAssertEqual(MessagePackValue(NSData(bytes: data, length: data.count)), MessagePackValue.Binary([0x00, 0x01, 0x02, 0x03, 0x04]))
        XCTAssertEqual(NSData(MessagePackValue.Binary([0x00, 0x01, 0x02, 0x03, 0x04])), NSData(bytes: data, length: data.count))
    }
}
