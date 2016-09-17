@testable import MessagePack
import XCTest

class ExampleTests: XCTestCase {
    let example: MessagePackValue = ["compact": true, "schema": 0]

    // Two possible "correct" values because dictionaries are unordered
    let correctA: MessagePack.Data = [0x82, 0xa7, 0x63, 0x6f, 0x6d, 0x70, 0x61, 0x63, 0x74, 0xc3, 0xa6, 0x73, 0x63, 0x68, 0x65, 0x6d, 0x61, 0x00]
    let correctB: MessagePack.Data = [0x82, 0xa6, 0x73, 0x63, 0x68, 0x65, 0x6d, 0x61, 0x00, 0xa7, 0x63, 0x6f, 0x6d, 0x70, 0x61, 0x63, 0x74, 0xc3]

    func testPack() {
        let packed = pack(example)
        XCTAssertTrue(packed == correctA || packed == correctB)
    }

    func testUnpack() {
        let unpacked1 = try? unpack(correctA)
        XCTAssertEqual(unpacked1, example)

        let unpacked2 = try? unpack(correctB)
        XCTAssertEqual(unpacked2, example)
    }

    func testUnpackInvalidData() {
        do {
            let _ = try unpack([0xc1])
            XCTFail("Expected unpack to throw")
        } catch {
            XCTAssertEqual(error as? MessagePackError, .invalidData)
        }
    }

    func testUnpackInsufficientData() {
        do {
            let _ = try unpack([0x82, 0xa7, 0x63, 0x6f, 0x6d, 0x70, 0x61, 0x63, 0x74, 0xc3, 0xa6, 0x73, 0x63, 0x68, 0x65, 0x6d, 0x61])
            XCTFail("Expected unpack to throw")
        } catch {
            XCTAssertEqual(error as? MessagePackError, .insufficientData)
        }
    }

    func testUnpackNSData() {
        let data = correctA.withUnsafeBufferPointer { buffer in
            return Foundation.Data(bytes: UnsafePointer<UInt8>(buffer.baseAddress!), count: buffer.count)
        }

        let unpacked = try? unpack(data)
        XCTAssertEqual(unpacked, example)
    }

    func testUnpackInsufficientNSData() {
        let bytes: MessagePack.Data = [0x82, 0xa7, 0x63, 0x6f, 0x6d, 0x70, 0x61, 0x63, 0x74, 0xc3, 0xa6, 0x73, 0x63, 0x68, 0x65, 0x6d]
        let data = bytes.withUnsafeBufferPointer { buffer in
            return Foundation.Data(bytes: UnsafePointer<UInt8>(buffer.baseAddress!), count: buffer.count)
        }

        do {
            let _ = try unpack(data)
            XCTFail("Expected unpack to throw")
        } catch {
            XCTAssertEqual(error as? MessagePackError, .insufficientData)
        }
    }

    func testUnpackDispatchData() {
        let data = correctA.withUnsafeBufferPointer { buffer in
            return DispatchData(bytesNoCopy: buffer, deallocator: .custom(nil, {}))
        }

        let unpacked = try? unpack(data)
        XCTAssertEqual(unpacked, example)
    }

    func testUnpackDiscontinuousDispatchData() {
        let bytesA: MessagePack.Data = [0x82, 0xa7, 0x63, 0x6f, 0x6d, 0x70, 0x61, 0x63]
        var dataA = bytesA.withUnsafeBufferPointer { buffer in
            return DispatchData(bytesNoCopy: buffer, deallocator: .custom(nil, {}))
        }

        let bytesB: MessagePack.Data = [0x74, 0xc3, 0xa6, 0x73, 0x63, 0x68, 0x65, 0x6d, 0x61, 0x00]
        let dataB = bytesB.withUnsafeBufferPointer { buffer in
            return DispatchData(bytesNoCopy: buffer, deallocator: .custom(nil, {}))
        }

        dataA.append(dataB)

        let unpacked = try? unpack(dataA)
        XCTAssertEqual(unpacked, example)
    }

    func testUnpackInsufficientDispatchData() {
        let bytes: MessagePack.Data = [0x82, 0xa7, 0x63, 0x6f, 0x6d, 0x70, 0x61, 0x63, 0x74, 0xc3, 0xa6, 0x73, 0x63, 0x68, 0x65, 0x6d]
        let data = bytes.withUnsafeBufferPointer { buffer in
            return DispatchData(bytesNoCopy: buffer, deallocator: .custom(nil, {}))
        }

        do {
            let _ = try unpack(data)
            XCTFail("Expected unpack to throw")
        } catch {
            XCTAssertEqual(error as? MessagePackError, .insufficientData)
        }
    }
}
