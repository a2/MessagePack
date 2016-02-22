import Data
import Foundation

/// Joins bytes from the generator to form an integer.
///
/// - parameter data: The input data to unpack.
/// - parameter size: The size of the integer.
///
/// - returns: An integer representation of `size` bytes of data.
func unpackInteger(data: Data<UInt8>, size: Int) throws -> (UInt64, Data<UInt8>) {
    guard data.count > size else { throw MessagePackError.InsufficientData }

    let value = data[0..<size].withUnsafeBufferPointer { buffer in
        return (0..<size).reduce(0 as UInt64) { value, i in value << 8 | UInt64(buffer[i]) }
    }
    return (value, data[size..<data.endIndex])
}

/// Joins bytes from the generator to form a string.
///
/// - parameter data: The input data to unpack.
/// - parameter length: The length of the string.
///
/// - returns: A string representation of `size` bytes of data.
func unpackString(data: Data<UInt8>, length: Int) throws -> (String, Data<UInt8>) {
    guard data.count > length else { throw MessagePackError.InsufficientData }

    if let string = data.decode(UTF8.self) {
        return (string, data[length..<data.endIndex])
    } else {
        throw MessagePackError.InvalidData
    }
}

/// Joins bytes from the generator to form a data object.
///
/// - parameter data: The input data to unpack.
/// - parameter length: The length of the data.
///
/// - returns: A subsection of data representing `size` bytes.
func unpackData(data: Data<UInt8>, length: Int) throws -> (Data<UInt8>, Data<UInt8>) {
    guard data.count > length else { throw MessagePackError.InsufficientData }

    return (data[0..<length], data[length..<data.endIndex])
}

/// Joins bytes from the generator to form an array of `MessagePackValue` values.
///
/// - parameter data: The input data to unpack.
/// - parameter count: The number of elements to unpack.
/// - parameter compatibility: Whether to prefer Binary over String.
///
/// - returns: An array of `count` elements.
func unpackArray(data: Data<UInt8>, count: Int, compatibility: Bool) throws -> ([MessagePackValue], Data<UInt8>) {
    var values = [MessagePackValue]()
    values.reserveCapacity(count)

    var remainder = data
    for _ in 0..<count {
        let result = try unpack(remainder, compatibility: compatibility)
        values.append(result.0)
        remainder = result.1
    }

    return (values, remainder)
}

/// Joins bytes from the generator to form a dictionary with entires of `MessagePackValue` keys/values.
///
/// - parameter data: The input data to unpack.
/// - parameter offset: The offset from which to begin unpacking.
/// - parameter count: The number of elements to unpack.
/// - parameter compatibility: Whether to prefer Binary over String.
///
/// - returns: An dictionary of `count` entries.
func unpackMap(data: Data<UInt8>, count: Int, compatibility: Bool) throws -> ([MessagePackValue : MessagePackValue], Data<UInt8>) {
    let (array, remainder) = try unpackArray(data, count: 2 * count, compatibility: compatibility)

    var dict = [MessagePackValue : MessagePackValue](minimumCapacity: count)
    for pair in array.slice(every: 2) {
        let key = pair[0]
        let value = pair[1]
        dict[key] = value
    }

    return (dict, remainder)
}

/// Unpacks a byte generator into a MessagePackValue.
///
/// - parameter data: The input data to unpack.
/// - parameter offset: The offset from which to begin unpacking.
///
/// - returns: A `MessagePackValue`.
public func unpack(data: Data<UInt8>, compatibility: Bool) throws -> (MessagePackValue, Data<UInt8>) {
    guard data.count > 1 else { throw MessagePackError.InsufficientData }

    // Read first byte
    let value = data[0..<1].withUnsafeBufferPointer { buffer in buffer[0] }

    switch value {

    // positive fixint
    case 0x00...0x7f:
        return (.UInt(numericCast(value)), data[1..<data.endIndex])

    // fixmap
    case 0x80...0x8f:
        let count = Int(value - 0x80)
        let (dict, remainder) = try unpackMap(data, count: count, compatibility: compatibility)
        return (.Map(dict), remainder)

    // fixarray
    case 0x90...0x9f:
        let count = Int(value - 0x90)
        let (array, remainder) = try unpackArray(data, count: count, compatibility: compatibility)
        return (.Array(array), remainder)

    // fixstr
    case 0xa0...0xbf:
        let length = Int(value - 0xa0)
        if compatibility {
            let (data, remainder) = try unpackData(data, length: length)
            return (.Binary(data), remainder)
        } else {
            let (string, remainder) = try unpackString(data, length: length)
            return (.String(string), remainder)
        }

    // nil
    case 0xc0:
        return (.Nil, data[1..<data.endIndex])

    // false
    case 0xc2:
        return (.Bool(false), data[1..<data.endIndex])

    // true
    case 0xc3:
        return (.Bool(true), data[1..<data.endIndex])

    // bin 8, 16, 32
    case 0xc4...0xc6:
        let size = 1 << numericCast(value - 0xc4)
        let (length, remainderA) = try unpackInteger(data, size: size)
        let (subdata, remainderB) = try unpackData(remainderA, length: numericCast(length))
        return (.Binary(subdata), remainderB)

    // ext 8, 16, 32
    case 0xc7...0xc9:
        let size = 1 << Int(value - 0xc7)
        let (length, remainderA) = try unpackInteger(data, size: size)
        guard remainderA.count > 1 else { throw MessagePackError.InsufficientData }

        let typeByte = remainderA[0..<1].withUnsafeBufferPointer { buffer in buffer[0] }
        let type = Int8(bitPattern: typeByte)
        let (data, remainderB) = try unpackData(remainderA[1..<remainderA.endIndex], length: numericCast(length))
        return (.Extended(type, data), remainderB)

    // float 32
    case 0xca:
        let (bytes, remainder) = try unpackInteger(data, size: 4)
        let float = unsafeBitCast(UInt32(truncatingBitPattern: bytes), Float.self)
        return (.Float(float), remainder)

    // float 64
    case 0xcb:
        let (bytes, remainder) = try unpackInteger(data, size: 8)
        let double = unsafeBitCast(bytes, Double.self)
        return (.Double(double), remainder)

    // uint 8, 16, 32, 64
    case 0xcc...0xcf:
        let size = 1 << (numericCast(value) - 0xcc)
        let (integer, remainder) = try unpackInteger(data, size: size)
        return (.UInt(integer), remainder)

    // int 8
    case 0xd0:
        guard data.count > 2 else { throw MessagePackError.InsufficientData }

        let byte = data[1..<2].withUnsafeBufferPointer { buffer in buffer[0] }
        let integer = Int8(bitPattern: byte)
        return (.Int(numericCast(integer)), data[2..<data.endIndex])


    // int 16
    case 0xd1:
        let (bytes, remainder) = try unpackInteger(data, size: 2)
        let integer = Int16(bitPattern: UInt16(truncatingBitPattern: bytes))
        return (.Int(numericCast(integer)), remainder)

    // int 32
    case 0xd2:
        let (bytes, remainder) = try unpackInteger(data, size: 4)
        let integer = Int32(bitPattern: UInt32(truncatingBitPattern: bytes))
        return (.Int(numericCast(integer)), remainder)

    // int 64
    case 0xd3:
        let (bytes, remainder) = try unpackInteger(data, size: 8)
        let integer = Int64(bitPattern: bytes)
        return (.Int(integer), remainder)

    // fixent 1, 2, 4, 8, 16
    case 0xd4...0xd8:
        let length = 1 << Int(value - 0xd4)
        guard data.count > 2 else { throw MessagePackError.InsufficientData }

        let typeByte = data[1..<2].withUnsafeBufferPointer { buffer in buffer[0] }
        let type = Int8(bitPattern: typeByte)
        let (bytes, remainder) = try unpackData(data[2..<data.endIndex], length: length)
        return (.Extended(type, bytes), remainder)

    // str 8, 16, 32
    case 0xd9...0xdb:
        let lengthSize = 1 << Int(value - 0xd9)
        let (length, remainderA) = try unpackInteger(data, size: lengthSize)
        if compatibility {
            let (data, remainderB) = try unpackData(remainderA, length: numericCast(length))
            return (.Binary(data), remainderB)
        } else {
            let (string, remainderB) = try unpackString(remainderA, length: numericCast(length))
            return (.String(string), remainderB)
        }

    // array 16, 32
    case 0xdc...0xdd:
        let countSize = 1 << Int(value - 0xdb)
        let (count, remainderA) = try unpackInteger(data, size: countSize)
        let (array, remainderB) = try unpackArray(remainderA, count: numericCast(count), compatibility: compatibility)
        return (.Array(array), remainderB)

    // map 16, 32
    case 0xde...0xdf:
        let countSize = 1 << Int(value - 0xdd)
        let (count, remainderA) = try unpackInteger(data, size: countSize)
        let (dict, remainderB) = try unpackMap(remainderA, count: numericCast(count), compatibility: compatibility)
        return (.Map(dict), remainderB)

    // negative fixint
    case 0xe0..<0xff:
        return (.Int(numericCast(value) - 0x100), data[1..<data.endIndex])

    // negative fixint (workaround for rdar://19779978)
    case 0xff:
        return (.Int(numericCast(value) - 0x100), data[1..<data.endIndex])

    default:
        throw MessagePackError.InvalidData
    }
}

/// Unpacks a data object in the form of `NSData` into a `MessagePackValue`.
///
/// - parameter data: The data to unpack.
/// - parameter compatibility: Whether to prefer Binary over String.
/// - parameter withRemainingData: A closure that receives the leftover data.
///
/// - returns: The contained `MessagePackValue`.
public func unpack(data: Data<UInt8>, compatibility: Bool = false, @noescape withRemainingData: (Data<UInt8>) throws -> Void) throws -> MessagePackValue {
    let (value, remainder) = try unpack(data, compatibility: compatibility)
    try withRemainingData(remainder)
    return value
}
