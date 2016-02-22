extension MessagePackValue {
    public init() {
        self = .Nil
    }

    public init(_ value: Swift.Bool) {
        self = .Bool(value)
    }

    public init<S: SignedIntegerType>(_ value: S) {
        self = .Int(numericCast(value))
    }

    public init<U: UnsignedIntegerType>(_ value: U) {
        self = .UInt(numericCast(value))
    }

    public init(_ value: Swift.Float) {
        self = .Float(value)
    }

    public init(_ value: Swift.Double) {
        self = .Double(value)
    }

    public init(_ value: Swift.String) {
        self = .String(value)
    }

    public init(_ value: [MessagePackValue]) {
        self = .Array(value)
    }

    public init(_ value: [MessagePackValue : MessagePackValue]) {
        self = .Map(value)
    }

    public init(_ value: Data) {
        self = .Binary(value)
    }
    
    public init(_ value: NSData) {
        var bytes = [UInt8](count: value.length, repeatedValue: 0)
        value.getBytes(&bytes, length: bytes.count)
        self = .Binary(bytes)
    }
}

extension Bool {
    public init?(_ value: MessagePackValue?) {
        guard let val = value?.boolValue else { return nil }
        self = val
    }
}

extension SignedIntegerType {
    public init?(_ value: MessagePackValue?) {
        guard let val = value?.integerValue else { return nil }
        self = numericCast(val)
    }
}

extension UnsignedIntegerType {
    public init?(_ value: MessagePackValue?) {
        guard let val = value?.unsignedIntegerValue else { return nil }
        self = numericCast(val)
    }
}

extension Double {
    public init?(_ value: MessagePackValue?) {
        guard let val = value?.doubleValue else { return nil }
        self = val
    }
}

extension Float {
    public init?(_ value: MessagePackValue?) {
        guard let val = value?.floatValue else { return nil }
        self = val
    }
    
}

extension StringLiteralType {
    public init?(_ value: MessagePackValue?) {
        guard let val = value?.stringValue else { return nil }
        self = val
    }
}

extension NSData {
    public convenience init?(_ value: MessagePackValue?) {
        guard let val = value?.dataValue else { return nil }
        self.init(data: NSData(bytes: val, length: val.count))
    }                                                                         
}