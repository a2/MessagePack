import Data

/// Packs an integer into a byte array.
///
/// - parameter value: The integer to split.
/// - parameter parts: The number of bytes into which to split.
///
/// - returns: An byte array representation.
func packInteger(value: UInt64, parts: Int) -> Data<UInt8> {
    precondition(parts > 0)
    let shifts = (8 * (parts - 1)).stride(through: 0, by: -8)
    let bytes = shifts.map { shift in UInt8(truncatingBitPattern: value >> numericCast(shift)) }
    return Data(array: bytes)
}

/// Packs an unsigned integer into an array of bytes.
///
/// - parameter value: The value to encode
///
/// - returns: A MessagePack byte representation.
func packPositiveInteger(value: UInt64) -> Data<UInt8> {
    switch value {
    case let value where value <= 0x7f:
        return Data(array: [UInt8(truncatingBitPattern: value)])
    case let value where value <= 0xff:
        return Data(array: [0xcc, UInt8(truncatingBitPattern: value)])
    case let value where value <= 0xffff:
        return Data(array: [0xcd]) + packInteger(value, parts: 2)
    case let value where value <= 0xffff_ffff:
        return Data(array: [0xce]) + packInteger(value, parts: 4)
    default:
        return Data(array: [0xcf]) + packInteger(value, parts: 8)
    }
}

/// Packs a signed integer into an array of bytes.
///
/// - parameter value: The value to encode
///
/// - returns: A MessagePack byte representation.
func packNegativeInteger(value: Int64) -> Data<UInt8> {
    precondition(value < 0)
    switch value {
    case let value where value >= -0x20:
        return Data(array: [0xe0 + 0x1f & UInt8(truncatingBitPattern: value)])
    case let value where value >= -0x7f:
        return Data(array: [0xd0, UInt8(bitPattern: numericCast(value))])
    case let value where value >= -0x7fff:
        let truncated = UInt16(bitPattern: numericCast(value))
        return Data(array: [0xd1]) + packInteger(numericCast(truncated), parts: 2)
    case let value where value >= -0x7fff_ffff:
        let truncated = UInt32(bitPattern: numericCast(value))
        return Data(array: [0xd2]) + packInteger(numericCast(truncated), parts: 4)
    default:
        let truncated = UInt64(bitPattern: value)
        return Data(array: [0xd3]) + packInteger(truncated, parts: 8)
    }
}

/// Packs a MessagePackValue into an array of bytes.
///
/// - parameter value: The value to encode
///
/// - returns: A MessagePack byte representation.
public func pack(value: MessagePackValue) -> Data<UInt8> {
    switch value {
    case .Nil:
        return Data(array: [0xc0])

    case let .Bool(value):
        return Data(array: [value ? 0xc3 : 0xc2])

    case let .Int(value):
        if value >= 0 {
            return packPositiveInteger(numericCast(value))
        } else {
            return packNegativeInteger(value)
        }

    case let .UInt(value):
        return packPositiveInteger(value)

    case let .Float(value):
        let integerValue = unsafeBitCast(value, UInt32.self)
        return Data(array: [0xca]) + packInteger(numericCast(integerValue), parts: 4)

    case let .Double(value):
        let integerValue = unsafeBitCast(value, UInt64.self)
        return Data(array: [0xcb]) + packInteger(integerValue, parts: 8)

    case let .String(string):
        var utf8 = string.nulTerminatedUTF8
        utf8.removeLast()

        let count = UInt32(utf8.count)
        precondition(count <= 0xffff_ffff)

        let prefix: Data<UInt8>
        switch count {
        case let count where count <= 0x19:
            prefix = Data(array: [0xa0 | numericCast(count)])
        case let count where count <= 0xff:
            prefix = Data(array: [0xd9, numericCast(count)])
        case let count where count <= 0xffff:
            prefix = Data(array: [0xda]) + packInteger(numericCast(count), parts: 2)
        default:
            prefix = Data(array: [0xdb]) + packInteger(numericCast(count), parts: 4)
        }

        return prefix + Data(array: utf8)

    case let .Binary(data):
        let count = UInt32(data.count)
        precondition(count <= 0xffff_ffff)

        let prefix: Data<UInt8>
        switch count {
        case let count where count <= 0xff:
            prefix = Data(array: [0xc4, numericCast(count)])
        case let count where count <= 0xffff:
            prefix = Data(array: [0xc5]) + packInteger(numericCast(count), parts: 2)
        default:
            prefix = Data(array: [0xc6]) + packInteger(numericCast(count), parts: 4)
        }

        return prefix + data

    case let .Array(array):
        let count = UInt32(array.count)
        precondition(count <= 0xffff_ffff)

        let prefix: Data<UInt8>
        switch count {
        case let count where count <= 0xe:
            prefix = Data(array: [0x90 | numericCast(count)])
        case let count where count <= 0xffff:
            prefix = Data(array: [0xdc]) + packInteger(numericCast(count), parts: 2)
        default:
            prefix = Data(array: [0xdd]) + packInteger(numericCast(count), parts: 4)
        }

        let arrayOfData = [prefix] + array.flatMap(pack)
        return arrayOfData.reduce(Data(), combine: +)

    case let .Map(dict):
        let count = UInt32(dict.count)
        precondition(count < 0xffff_ffff)

        var prefix: Data<UInt8>
        switch count {
        case let count where count <= 0xe:
            prefix = Data(array: [0x80 | numericCast(count)])
        case let count where count <= 0xffff:
            prefix = Data(array: [0xde]) + packInteger(numericCast(count), parts: 2)
        default:
            prefix = Data(array: [0xdf]) + packInteger(numericCast(count), parts: 4)
        }

        let arrayOfData = [prefix] + dict.flatMap { [$0, $1] }.flatMap(pack)
        return arrayOfData.reduce(Data(), combine: +)

    case let .Extended(type, data):
        let count = UInt32(data.count)
        precondition(count <= 0xffff_ffff)

        let unsignedType = UInt8(bitPattern: type)
        let prefix: Data<UInt8>
        switch count {
        case 1:
            prefix = Data(array: [0xd4, unsignedType])
        case 2:
            prefix = Data(array: [0xd5, unsignedType])
        case 4:
            prefix = Data(array: [0xd6, unsignedType])
        case 8:
            prefix = Data(array: [0xd7, unsignedType])
        case 16:
            prefix = Data(array: [0xd8, unsignedType])
        case let count where count <= 0xff:
            prefix = Data(array: [0xc7, numericCast(count), unsignedType])
        case let count where count <= 0xffff:
            prefix = Data(array: [0xc8]) + packInteger(numericCast(count), parts: 2) + Data(array: [unsignedType])
        default:
            prefix = Data(array: [0xc9]) + packInteger(numericCast(count), parts: 4) + Data(array: [unsignedType])
        }

        return prefix + data
    }
}
