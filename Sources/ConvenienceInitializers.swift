import Data

extension MessagePackValue {
    public init() {
        self = .Nil
    }

    public init(_ value: Swift.Bool) {
        self = .Bool(value)
    }

    public init<T: SignedIntegerType>(_ value: T) {
        self = .Int(numericCast(value))
    }

    public init<T: UnsignedIntegerType>(_ value: T) {
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

    public init<T>(_ value: Data<T>) {
        self = .Binary(try! Data(value.data))
    }
}
