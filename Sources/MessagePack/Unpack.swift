
import Foundation

final class RemainderData {
  let data:Data
  private let bytes:UnsafePointer<UInt8>
  private let rawBytes:UnsafeRawPointer
  private var offset:Int = 0 {
    didSet {
      isEmpty = offset >= data.endIndex
    }
  }
  init(_ data:Data) {
    self.data = data
    rawBytes = (self.data as! NSData).bytes
    bytes = rawBytes.assumingMemoryBound(to: UInt8.self)
    isEmpty = data.isEmpty
  }
  
  
  private (set) var isEmpty: Bool
  
  var first: UInt8? {
    guard !isEmpty else {
      return nil
    }
    
    return data[offset]
  }
  
  var count: Int {
    return data.endIndex - offset
  }
  
  func inc(_ size:Int) {
    offset += size
  }
  
  func popOne() -> UInt8 {
    let v = bytes[offset]
    offset += 1
    return v
  }
  
  func pop<T>(_ type: T.Type, inc:Int) -> T {
    let v:T = rawBytes.load(fromByteOffset: offset, as: T.self)
    
    offset += inc
    return v
  }
  
  func popData(first size:Int) -> Data {
    let value = data.subdata(in: offset..<(offset+size))
    offset += size
    return value
  }
  
  func popRemaining() -> Data {
    return popData(first: count)
  }
  
  //  func process<T>(first times:Int, with window:(_ rootData:Data, _ offset:Int)-> T) {
  //    guard times > 0 else {
  //      return nil
  //    }
  //
  //    guard times <= count else {
  //      return nil
  //    }
  //
  //    let values = data[offset..<(offset + times)]
  //    offset += times
  //    return nil
  //  }
  //  var dropFirst
}


/// Joins bytes to form an integer.
///
/// - parameter data: The input data to unpack.
/// - parameter size: The size of the integer.
///
/// - returns: An integer representation of `size` bytes of data.
func unpackInteger(_ data: RemainderData, count: Int) throws -> (value: UInt64, remainder: RemainderData) {
    guard count > 0 else {
        throw MessagePackError.invalidArgument
    }

    guard data.count >= count else {
        throw MessagePackError.insufficientData
    }

    var value: UInt64 = 0
    for i in 0 ..< count {
    let byte = data.popOne()
        value = value << 8 | UInt64(byte)
    }

  return (value, data)
}

/// Joins bytes to form a string.
///
/// - parameter data: The input data to unpack.
/// - parameter length: The length of the string.
///
/// - returns: A string representation of `size` bytes of data.
func unpackString(_ data: RemainderData, count: Int) throws -> (value: String, remainder: RemainderData) {
    guard count > 0 else {
        return ("", data)
    }

    guard data.count >= count else {
        throw MessagePackError.insufficientData
    }


  let subdata = data.popData(first: count)
    guard let result = String(data: subdata, encoding: .utf8) else {
        throw MessagePackError.invalidData
    }

  return (result, data)
}

/// Joins bytes to form a data object.
///
/// - parameter data: The input data to unpack.
/// - parameter length: The length of the data.
///
/// - returns: A subsection of data representing `size` bytes.
func unpackData(_ data: RemainderData, count: Int) throws -> (value: Data, remainder: RemainderData) {
    guard count > 0 else {
        throw MessagePackError.invalidArgument
    }

    guard data.count >= count else {
        throw MessagePackError.insufficientData
    }
  let subData = data.popData(first: count)
  return (subData, data)
}

/// Joins bytes to form an array of `MessagePackValue` values.
///
/// - parameter data: The input data to unpack.
/// - parameter count: The number of elements to unpack.
///
/// - returns: An array of `count` elements.
func unpackArray(_ data: RemainderData, count: Int, compatibility: Bool) throws -> (value: [MessagePackValue], remainder: RemainderData) {
  var values = [MessagePackValue]()
    var newValue: MessagePackValue
  var remainder:RemainderData = data
    for _ in 0 ..< count {
        (newValue, remainder) = try unpack(remainder, compatibility: compatibility)
        values.append(newValue)
    }

    return (values, remainder)
}

/// Joins bytes to form a dictionary with `MessagePackValue` key/value entries.
///
/// - parameter data: The input data to unpack.
/// - parameter count: The number of elements to unpack.
///
/// - returns: An dictionary of `count` entries.
func unpackMap(_ data: RemainderData, count: Int, compatibility: Bool) throws -> (value: [MessagePackValue: MessagePackValue], remainder: RemainderData) {
    var dict = [MessagePackValue: MessagePackValue](minimumCapacity: count)
    var lastKey: MessagePackValue? = nil

    let (array, remainder) = try unpackArray(data, count: 2 * count, compatibility: compatibility)
    for item in array {
        if let key = lastKey {
            dict[key] = item
            lastKey = nil
        } else {
            lastKey = item
        }
    }

    return (dict, remainder)
}

/// Unpacks data into a MessagePackValue and returns the remaining data.
///
/// - parameter data: The input data to unpack.
///
/// - returns: A `MessagePackValue`.
public func unpack(_ data: Data, compatibility: Bool = false) throws -> (value: MessagePackValue, remainder: Data) {
  let (value, remainder) = try unpack(RemainderData(data), compatibility: compatibility)
  return (value, remainder.popRemaining())
}



func unpack(_ data: RemainderData, compatibility: Bool = false) throws -> (value: MessagePackValue, remainder: RemainderData) {
    guard !data.isEmpty else {
        throw MessagePackError.insufficientData
    }

  let value = data.popOne()

    switch value {

    // positive fixint
    case 0x00 ... 0x7f:
        return (.uint(UInt64(value)), data)

    // fixmap
    case 0x80 ... 0x8f:
        let count = Int(value - 0x80)
        let (dict, remainder) = try unpackMap(data, count: count, compatibility: compatibility)
        return (.map(dict), remainder)

    // fixarray
    case 0x90 ... 0x9f:
        let count = Int(value - 0x90)
        let (array, remainder) = try unpackArray(data, count: count, compatibility: compatibility)
        return (.array(array), remainder)

    // fixstr
    case 0xa0 ... 0xbf:
        let count = Int(value - 0xa0)
        if compatibility {
            let (data, remainder) = try unpackData(data, count: count)
            return (.binary(data), remainder)
        } else {
            let (string, remainder) = try unpackString(data, count: count)
            return (.string(string), remainder)
        }

    // nil
    case 0xc0:
        return (.nil, data)

    // false
    case 0xc2:
        return (.bool(false), data)

    // true
    case 0xc3:
        return (.bool(true), data)

    // bin 8, 16, 32
    case 0xc4 ... 0xc6:
        let intCount = 1 << Int(value - 0xc4)
        let (dataCount, remainder1) = try unpackInteger(data, count: intCount)
        let (subdata, remainder2) = try unpackData(remainder1, count: Int(dataCount))
        return (.binary(subdata), remainder2)

    // ext 8, 16, 32
    case 0xc7 ... 0xc9:
        let intCount = 1 << Int(value - 0xc7)

        let (dataCount, remainder1) = try unpackInteger(data, count: intCount)
        guard !remainder1.isEmpty else {
            throw MessagePackError.insufficientData
        }

    let type = Int8(bitPattern: remainder1.popOne())
    let (data, remainder2) = try unpackData(remainder1, count: Int(dataCount))
        return (.extended(type, data), remainder2)

    // float 32
    case 0xca:
        let (intValue, remainder) = try unpackInteger(data, count: 4)
        let float = Float(bitPattern: UInt32(truncatingBitPattern: intValue))
        return (.float(float), remainder)

    // float 64
    case 0xcb:
        let (intValue, remainder) = try unpackInteger(data, count: 8)
        let double = Double(bitPattern: intValue)
        return (.double(double), remainder)

    // uint 8, 16, 32, 64
    case 0xcc ... 0xcf:
        let count = 1 << (Int(value) - 0xcc)
        let (integer, remainder) = try unpackInteger(data, count: count)
        return (.uint(integer), remainder)

    // int 8
    case 0xd0:
        guard !data.isEmpty else {
            throw MessagePackError.insufficientData
        }

    let byte = Int8(bitPattern: data.popOne())
    return (.int(Int64(byte)), data)

    // int 16
    case 0xd1:
        let (bytes, remainder) = try unpackInteger(data, count: 2)
        let integer = Int16(bitPattern: UInt16(truncatingBitPattern: bytes))
        return (.int(Int64(integer)), remainder)

    // int 32
    case 0xd2:
        let (bytes, remainder) = try unpackInteger(data, count: 4)
        let integer = Int32(bitPattern: UInt32(truncatingBitPattern: bytes))
        return (.int(Int64(integer)), remainder)

    // int 64
    case 0xd3:
        let (bytes, remainder) = try unpackInteger(data, count: 8)
        let integer = Int64(bitPattern: bytes)
        return (.int(integer), remainder)

    // fixent 1, 2, 4, 8, 16
    case 0xd4 ... 0xd8:
        let count = 1 << Int(value - 0xd4)

        guard !data.isEmpty else {
            throw MessagePackError.insufficientData
        }

    let type = Int8(bitPattern: data.popOne())
    let (bytes, remainder) = try unpackData(data, count: count)
        return (.extended(type, bytes), remainder)

    // str 8, 16, 32
    case 0xd9 ... 0xdb:
        let countSize = 1 << Int(value - 0xd9)
        let (count, remainder1) = try unpackInteger(data, count: countSize)
        if compatibility {
            let (data, remainder2) = try unpackData(remainder1, count: Int(count))
            return (.binary(data), remainder2)
        } else {
            let (string, remainder2) = try unpackString(remainder1, count: Int(count))
            return (.string(string), remainder2)
        }

    // array 16, 32
    case 0xdc ... 0xdd:
        let countSize = 1 << Int(value - 0xdb)
        let (count, remainder1) = try unpackInteger(data, count: countSize)
        let (array, remainder2) = try unpackArray(remainder1, count: Int(count), compatibility: compatibility)
        return (.array(array), remainder2)

    // map 16, 32
    case 0xde ... 0xdf:
        let countSize = 1 << Int(value - 0xdd)
        let (count, remainder1) = try unpackInteger(data, count: countSize)
        let (dict, remainder2) = try unpackMap(remainder1, count: Int(count), compatibility: compatibility)
        return (.map(dict), remainder2)

    // negative fixint
    case 0xe0 ..< 0xff:
        return (.int(Int64(value) - 0x100), data)

    // negative fixint (workaround for rdar://19779978)
    case 0xff:
        return (.int(Int64(value) - 0x100), data)

    default:
        throw MessagePackError.invalidData
    }
}

/// Unpacks a data object into a `MessagePackValue`, ignoring excess data.
///
/// - parameter data: The data to unpack.
///
/// - returns: The contained `MessagePackValue`.
public func unpackFirst(_ data: Data, compatibility: Bool = false) throws -> MessagePackValue {
    return try unpack(data, compatibility: compatibility).value
}

/// Unpacks a data object into an array of `MessagePackValue` values.
///
/// - parameter data: The data to unpack.
///
/// - returns: The contained `MessagePackValue` values.
public func unpackAll(_ data: Data, compatibility: Bool = false) throws -> [MessagePackValue] {
    var values = [MessagePackValue]()

    var data = data
    while !data.isEmpty {
        let value: MessagePackValue
        (value, data) = try unpack(data, compatibility: compatibility)
        values.append(value)
    }

    return values
}
