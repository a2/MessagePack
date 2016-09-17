/// Joins bytes from the generator to form an integer.
///
/// - parameter generator: The input generator to unpack.
/// - parameter size: The size of the integer.
///
/// - returns: An integer representation of `size` bytes of data.
func unpackInteger<G: IteratorProtocol>(_ generator: inout G, size: Int) throws -> UInt64 where G.Element == Byte {
    var value: UInt64 = 0
    for _ in 0..<size {
        if let byte = generator.next() {
            value = value << 8 | numericCast(byte)
        } else {
            throw MessagePackError.insufficientData
        }
    }

    return value
}

/// Joins bytes from the generator to form a string.
///
/// - parameter generator: The input generator to unpack.
/// - parameter length: The length of the string.
///
/// - returns: A string representation of `size` bytes of data.
func unpackString<G: IteratorProtocol>(_ generator: inout G, length: Int) throws -> String where G.Element == Byte {
    var bytes = Data()
    bytes.reserveCapacity(length)

    for _ in 0..<length {
        if let byte = generator.next() {
            bytes.append(byte)
        } else {
            throw MessagePackError.insufficientData
        }
    }

    if let result = String(bytes: bytes, encoding: String.Encoding.utf8) {
        return result
    } else {
        throw MessagePackError.invalidData
    }
}

/// Joins bytes from the generator to form a data object.
///
/// - parameter generator: The input generator to unpack.
/// - parameter length: The length of the data.
///
/// - returns: A subsection of data representing `size` bytes.
func unpackData<G: IteratorProtocol>(_ generator: inout G, length: Int) throws -> Data where G.Element == Byte {
    var data = Data()
    data.reserveCapacity(length)

    for _ in 0..<length {
        if let byte = generator.next() {
            data.append(byte)
        } else {
            throw MessagePackError.insufficientData
        }
    }

    return data
}

/// Joins bytes from the generator to form an array of `MessagePackValue` values.
///
/// - parameter generator: The input generator to unpack.
/// - parameter count: The number of elements to unpack.
///
/// - returns: An array of `count` elements.
func unpackArray<G: IteratorProtocol>(_ generator: inout G, count: Int, compatibility: Bool) throws -> [MessagePackValue] where G.Element == Byte {
    var values = [MessagePackValue]()
    values.reserveCapacity(count)

    for _ in 0..<count {
        let value = try unpack(&generator, compatibility: compatibility)
        values.append(value)
    }

    return values
}

/// Joins bytes from the generator to form a dictionary with entires of `MessagePackValue` keys/values.
///
/// - parameter generator: The input generator to unpack.
/// - parameter count: The number of elements to unpack.
///
/// - returns: An dictionary of `count` entries.
func unpackMap<G: IteratorProtocol>(_ generator: inout G, count: Int, compatibility: Bool) throws -> [MessagePackValue : MessagePackValue] where G.Element == Byte {
    var dict = [MessagePackValue : MessagePackValue](minimumCapacity: count)
    var lastKey: MessagePackValue? = nil

    let array = try unpackArray(&generator, count: 2 * count, compatibility: compatibility)
    for item in array {
        if let key = lastKey {
            dict[key] = item
            lastKey = nil
        } else {
            lastKey = item
        }
    }

    return dict
}

/// Unpacks a byte generator into a MessagePackValue.
///
/// - parameter generator: The input generator to unpack.
///
/// - returns: A `MessagePackValue`.
public func unpack<G: IteratorProtocol>(_ generator: inout G, compatibility: Bool = false) throws -> MessagePackValue where G.Element == Byte {
    if let value = generator.next() {
        switch value {

        // positive fixint
        case 0x00...0x7f:
            return .uInt(numericCast(value))

        // fixmap
        case 0x80...0x8f:
            let count = Int(value - 0x80)
            let dict = try unpackMap(&generator, count: count, compatibility: compatibility)
            return .map(dict)

        // fixarray
        case 0x90...0x9f:
            let count = Int(value - 0x90)
            let array = try unpackArray(&generator, count: count, compatibility: compatibility)
            return .array(array)

        // fixstr
        case 0xa0...0xbf:
            let length = Int(value - 0xa0)
            if compatibility {
                let data = try unpackData(&generator, length: length)
                return .binary(data)
            } else {
                let string = try unpackString(&generator, length: length)
                return .string(string)
            }


        // nil
        case 0xc0:
            return .nil

        // false
        case 0xc2:
            return .bool(false)

        // true
        case 0xc3:
            return .bool(true)

        // bin 8, 16, 32
        case 0xc4...0xc6:
            let size = 1 << numericCast(value - 0xc4)
            let length = try unpackInteger(&generator, size: size)
            let subdata = try unpackData(&generator, length: numericCast(length))
            return .binary(subdata)

        // ext 8, 16, 32
        case 0xc7...0xc9:
            let size = 1 << Int(value - 0xc7)
            let length = try unpackInteger(&generator, size: size)
            if let typeByte = generator.next() {
                let type = Int8(bitPattern: typeByte)
                let data = try unpackData(&generator, length: numericCast(length))
                return .extended(type, data)
            } else {
                throw MessagePackError.insufficientData
            }

        // float 32
        case 0xca:
            let bytes = try unpackInteger(&generator, size: 4)
            let float = unsafeBitCast(UInt32(truncatingBitPattern: bytes), to: Float.self)
            return .float(float)

        // float 64
        case 0xcb:
            let bytes = try unpackInteger(&generator, size: 8)
            let double = unsafeBitCast(bytes, to: Double.self)
            return .double(double)

        // uint 8, 16, 32, 64
        case 0xcc...0xcf:
            let size = 1 << (numericCast(value) - 0xcc)
            let integer = try unpackInteger(&generator, size: size)
            return .uInt(integer)

        // int 8
        case 0xd0:
            if let byte = generator.next() {
                let integer = Int8(bitPattern: byte)
                return .int(numericCast(integer))
            } else {
                throw MessagePackError.insufficientData
            }

        // int 16
        case 0xd1:
            let bytes = try unpackInteger(&generator, size: 2)
            let integer = Int16(bitPattern: UInt16(truncatingBitPattern: bytes))
            return .int(numericCast(integer))

        // int 32
        case 0xd2:
            let bytes = try unpackInteger(&generator, size: 4)
            let integer = Int32(bitPattern: UInt32(truncatingBitPattern: bytes))
            return .int(numericCast(integer))

        // int 64
        case 0xd3:
            let bytes = try unpackInteger(&generator, size: 8)
            let integer = Int64(bitPattern: bytes)
            return .int(integer)

        // fixent 1, 2, 4, 8, 16
        case 0xd4...0xd8:
            let length = 1 << Int(value - 0xd4)
            if let typeByte = generator.next() {
                let type = Int8(bitPattern: typeByte)
                let bytes = try unpackData(&generator, length: length)
                return .extended(type, bytes)
            } else {
                throw MessagePackError.insufficientData
            }

        // str 8, 16, 32
        case 0xd9...0xdb:
            let lengthSize = 1 << Int(value - 0xd9)
            let length = try unpackInteger(&generator, size: lengthSize)
            if compatibility {
                let data = try unpackData(&generator, length: numericCast(length))
                return .binary(data)
            } else {
                let string = try unpackString(&generator, length: numericCast(length))
                return .string(string)
            }

        // array 16, 32
        case 0xdc...0xdd:
            let countSize = 1 << Int(value - 0xdb)
            let count = try unpackInteger(&generator, size: countSize)
            let array = try unpackArray(&generator, count: numericCast(count), compatibility: compatibility)
            return .array(array)

        // map 16, 32
        case 0xde...0xdf:
            let countSize = 1 << Int(value - 0xdd)
            let count = try unpackInteger(&generator, size: countSize)
            let dict = try unpackMap(&generator, count: numericCast(count), compatibility: compatibility)
            return .map(dict)

        // negative fixint
        case 0xe0..<0xff:
            return .int(numericCast(value) - 0x100)

        // negative fixint (workaround for rdar://19779978)
        case 0xff:
            return .int(numericCast(value) - 0x100)

        default:
            throw MessagePackError.invalidData
        }
    } else {
        throw MessagePackError.insufficientData
    }
}

/// Unpacks a data object in the form of `NSData` into a `MessagePackValue`.
///
/// - parameter data: The data to unpack.
///
/// - returns: The contained `MessagePackValue`.
public func unpack(_ data: Foundation.Data, compatibility: Bool = false) throws -> MessagePackValue {
    var generator = NSDataGenerator(data: data as NSData)
    return try unpack(&generator, compatibility: compatibility)
}

/// Unpacks a data object in the form of `dispatch_data_t` into a `MessagePackValue`.
///
/// - parameter data: The data to unpack.
///
/// - returns: The contained `MessagePackValue`.
public func unpack(_ data: DispatchData, compatibility: Bool = false) throws -> MessagePackValue {
    var generator = DispatchDataGenerator(data: data)
    return try unpack(&generator, compatibility: compatibility)
}

/// Unpacks a data object in the form of a byte array into a `MessagePackValue`.
///
/// - parameter data: The data to unpack.
///
/// - returns: The contained `MessagePackValue`.
public func unpack<S: Sequence>(_ data: S, compatibility: Bool = false) throws -> MessagePackValue where S.Iterator.Element == Byte {
    var generator = data.makeIterator()
    return try unpack(&generator, compatibility: compatibility)
}
