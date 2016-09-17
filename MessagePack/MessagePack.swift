public typealias Byte = UInt8
public typealias Data = [Byte]

/// The MessagePackValue enum encapsulates one of the following types: Nil, Bool, Int, UInt, Float, Double, String, Binary, Array, Map, and Extended.
public enum MessagePackValue {
    case `nil`
    case bool(Swift.Bool)
    case int(Int64)
    case uInt(UInt64)
    case float(Swift.Float)
    case double(Swift.Double)
    case string(Swift.String)
    case binary(Data)
    case array([MessagePackValue])
    case map([MessagePackValue : MessagePackValue])
    case extended(Int8, Data)
}

extension MessagePackValue: Hashable {
    public var hashValue: Swift.Int {
        switch self {
        case .nil: return 0
        case .bool(let value): return value.hashValue
        case .int(let value): return value.hashValue
        case .uInt(let value): return value.hashValue
        case .float(let value): return value.hashValue
        case .double(let value): return value.hashValue
        case .string(let string): return string.hashValue
        case .binary(let data): return data.count
        case .array(let array): return array.count
        case .map(let dict): return dict.count
        case .extended(let type, let data): return type.hashValue ^ data.count
        }
    }
}

public func ==(lhs: MessagePackValue, rhs: MessagePackValue) -> Bool {
    switch (lhs, rhs) {
    case (.nil, .nil):
        return true
    case let (.bool(lhv), .bool(rhv)):
        return lhv == rhv
    case let (.int(lhv), .int(rhv)):
        return lhv == rhv
    case let (.uInt(lhv), .uInt(rhv)):
        return lhv == rhv
    case let (.int(lhv), .uInt(rhv)):
        return lhv >= 0 && numericCast(lhv) == rhv
    case let (.uInt(lhv), .int(rhv)):
        return rhv >= 0 && lhv == numericCast(rhv)
    case let (.float(lhv), .float(rhv)):
        return lhv == rhv
    case let (.double(lhv), .double(rhv)):
        return lhv == rhv
    case let (.string(lhv), .string(rhv)):
        return lhv == rhv
    case let (.binary(lhv), .binary(rhv)):
        return lhv == rhv
    case let (.array(lhv), .array(rhv)):
        return lhv == rhv
    case let (.map(lhv), .map(rhv)):
        return lhv == rhv
    case let (.extended(lht, lhb), .extended(rht, rhb)):
        return lht == rht && lhb == rhb
    default:
        return false
    }
}

extension MessagePackValue: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .nil:
            return "Nil"
        case let .bool(value):
            return "Bool(\(value))"
        case let .int(value):
            return "Int(\(value))"
        case let .uInt(value):
            return "UInt(\(value))"
        case let .float(value):
            return "Float(\(value))"
        case let .double(value):
            return "Double(\(value))"
        case let .string(string):
            return "String(\(string))"
        case let .binary(data):
            return "Data(\(dataDescription(data)))"
        case let .array(array):
            return "Array(\(array.description))"
        case let .map(dict):
            return "Map(\(dict.description))"
        case let .extended(type, data):
            return "Extended(\(type), \(dataDescription(data)))"
        }
    }
}

public enum MessagePackError: Error {
    case insufficientData
    case invalidData
}

func dataDescription(_ data: Data) -> String {
    let bytes = data.map { byte -> String in
        let prefix: String
        if byte < 0x10 {
            prefix = "0x0"
        } else {
            prefix = "0x"
        }

        return prefix + String(byte, radix: 16)
    }

    return "[" + bytes.joined(separator: ", ") + "]"
}
