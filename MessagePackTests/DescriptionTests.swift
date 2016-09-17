@testable import MessagePack
import XCTest

class DescriptionTests: XCTestCase {
    func testNilDescription() {
        XCTAssertEqual(MessagePackValue.nil.description, "Nil")
    }

    func testBoolDescription() {
        XCTAssertEqual(MessagePackValue.bool(true).description, "Bool(true)")
        XCTAssertEqual(MessagePackValue.bool(false).description, "Bool(false)")
    }

    func testIntDescription() {
        XCTAssertEqual(MessagePackValue.int(-1).description, "Int(-1)")
        XCTAssertEqual(MessagePackValue.int(0).description, "Int(0)")
        XCTAssertEqual(MessagePackValue.int(1).description, "Int(1)")
    }

    func testUIntDescription() {
        XCTAssertEqual(MessagePackValue.uInt(0).description, "UInt(0)")
        XCTAssertEqual(MessagePackValue.uInt(1).description, "UInt(1)")
        XCTAssertEqual(MessagePackValue.uInt(2).description, "UInt(2)")
    }

    func testFloatDescription() {
        XCTAssertEqual(MessagePackValue.float(0.0).description, "Float(0.0)")
        XCTAssertEqual(MessagePackValue.float(1.618).description, "Float(1.618)")
        XCTAssertEqual(MessagePackValue.float(3.14).description, "Float(3.14)")
    }

    func testDoubleDescription() {
        XCTAssertEqual(MessagePackValue.double(0.0).description, "Double(0.0)")
        XCTAssertEqual(MessagePackValue.double(1.618).description, "Double(1.618)")
        XCTAssertEqual(MessagePackValue.double(3.14).description, "Double(3.14)")
    }

    func testStringDescription() {
        XCTAssertEqual(MessagePackValue.string("").description, "String()".description)
        XCTAssertEqual(MessagePackValue.string("MessagePack").description, "String(MessagePack)".description)
    }

    func testBinaryDescription() {
        XCTAssertEqual(MessagePackValue.binary([]).description, "Data([])")
        XCTAssertEqual(MessagePackValue.binary([0x00, 0x01, 0x02, 0x03, 0x04]).description, "Data([0x00, 0x01, 0x02, 0x03, 0x04])")
    }

    func testArrayDescription() {
        let values: [MessagePackValue] = [1, true, ""]
        XCTAssertEqual(MessagePackValue.array(values).description, "Array([Int(1), Bool(true), String()])")
    }

    func testMapDescription() {
        let values: [MessagePackValue : MessagePackValue] = [
            "a": "apple",
            "b": "banana",
            "c": "cookie",
        ]

        let components = [
            "String(a): String(apple)",
            "String(b): String(banana)",
            "String(c): String(cookie)",
        ]

        let indexPermutations: [[Int]] = [
            [0, 1, 2],
            [0, 2, 1],
            [1, 0, 2],
            [1, 2, 0],
            [2, 0, 1],
            [2, 1, 0],
        ]

        let description = MessagePackValue.map(values).description

        var isValid = false
        for indices in indexPermutations {
            let permutation = indices.map { (i) in components[i] }
            let innerDescription = permutation.joined(separator: ", ")
            if description == "Map([\(innerDescription)])" {
                isValid = true
                break
            }
        }

        XCTAssertTrue(isValid)
    }

    func testExtendedDescription() {
        XCTAssertEqual(MessagePackValue.extended(5, []).description, "Extended(5, [])")
        XCTAssertEqual(MessagePackValue.extended(5, [0x00, 0x10, 0x20, 0x30, 0x40]).description, "Extended(5, [0x00, 0x10, 0x20, 0x30, 0x40])")
    }
}
