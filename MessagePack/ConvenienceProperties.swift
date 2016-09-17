extension MessagePackValue {
    /// The number of elements in the `.Array` or `.Map`, `nil` otherwise.
    public var count: Swift.Int? {
        switch self {
        case let .array(array):
            return array.count
        case let .map(dict):
            return dict.count
        default:
            return nil
        }
    }

    /// The element at subscript `i` in the `.Array`, `nil` otherwise.
    public subscript (i: Swift.Int) -> MessagePackValue? {
        switch self {
        case let .array(array):
            return i < array.count ? array[i] : Optional.none
        default:
            return nil
        }
    }

    /// The element at keyed subscript `key`, `nil` otherwise.
    public subscript (key: MessagePackValue) -> MessagePackValue? {
        switch self {
        case let .map(dict):
            return dict[key]
        default:
            return nil
        }
    }

    /// True if `.Nil`, false otherwise.
    public var isNil: Swift.Bool {
        switch self {
        case .nil:
            return true
        default:
            return false
        }
    }

    /// The integer value if `.Int` or an appropriately valued `.UInt`, `nil` otherwise.
    public var integerValue: Int64? {
        switch self {
        case let .int(value):
            return value
        case let .uInt(value) where value < numericCast(Swift.Int64.max):
            return numericCast(value) as Int64
        default:
            return nil
        }
    }

    /// The unsigned integer value if `.UInt` or positive `.Int`, `nil` otherwise.
    public var unsignedIntegerValue: UInt64? {
        switch self {
        case let .int(value) where value >= 0:
            return numericCast(value) as UInt64
        case let .uInt(value):
            return value
        default:
            return nil
        }
    }

    /// The contained array if `.Array`, `nil` otherwise.
    public var arrayValue: [MessagePackValue]? {
        switch self {
        case let .array(array):
            return array
        default:
            return nil
        }
    }

    /// The contained boolean value if `.Bool`, `nil` otherwise.
    public var boolValue: Swift.Bool? {
        switch self {
        case let .bool(value):
            return value
        default:
            return nil
        }
    }

    /// The contained floating point value if `.Float` or `.Double`, `nil` otherwise.
    public var floatValue: Swift.Float? {
        switch self {
        case let .float(value):
            return value
        case let .double(value):
            return Swift.Float(value)
        default:
            return nil
        }
    }

    /// The contained double-precision floating point value if `.Float` or `.Double`, `nil` otherwise.
    public var doubleValue: Swift.Double? {
        switch self {
        case let .float(value):
            return Swift.Double(value)
        case let .double(value):
            return value
        default:
            return nil
        }
    }

    /// The contained string if `.String`, `nil` otherwise.
    public var stringValue: Swift.String? {
        switch self {
        case .binary(let data):
            var result = ""
            result.reserveCapacity(data.count)
            for byte in data {
                result.append(Character(UnicodeScalar(byte)))
            }
            return result
        case let .string(string):
            return string
        default:
            return nil
        }
    }

    /// The contained data if `.Binary` or `.Extended`, `nil` otherwise.
    public var dataValue: Data? {
        switch self {
        case let .binary(bytes):
            return bytes
        case let .extended(_, data):
            return data
        default:
            return nil
        }
    }

    /// The contained type and data if Extended, `nil` otherwise.
    public var extendedValue: (Int8, Data)? {
        switch self {
        case let .extended(type, data):
            return (type, data)
        default:
            return nil
        }
    }

    /// The contained type if `.Extended`, `nil` otherwise.
    public var extendedType: Int8? {
        switch self {
        case let .extended(type, _):
            return type
        default:
            return nil
        }
    }

    /// The contained dictionary if `.Map`, `nil` otherwise.
    public var dictionaryValue: [MessagePackValue : MessagePackValue]? {
        switch self {
        case let .map(dict):
            return dict
        default:
            return nil
        }
    }
}
