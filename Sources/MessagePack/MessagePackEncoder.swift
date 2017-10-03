import Foundation

/*
 * The implementation of MessagePackEncoder/Decoder heavily references JSONEncoder.swift and PlistEncoder.swift
 * from the Swift foundation library. As the logic required to implement this correctly is non-trivial and
 * complicated, I kept the structure pretty much the same as JSONEncoder and PlistEncoder so that it is easy
 * for anyone to cross reference. For your info, JSONEncoder is a single file with 2.1k lines of code =x.
 *
 * Warning for anyone who wants to modify this file, please make sure you understood all the code in JSONEncoder.swift
 * and PlistEncoder.swift before doing so. There are reasons for why things are done in a particular way.
 *
 * Swift repo commit at time of reference: 24821ccb08832e5d6ef5d21d6730b51f93d9d210
 */

// MARK: - MessagePackEncoder

open class MessagePackEncoder {
    
    open var userInfo: [CodingUserInfoKey : Any] = [:]
    
    fileprivate struct _Options {
        let userInfo: [CodingUserInfoKey : Any]
    }
    
    fileprivate var options: _Options {
        return _Options(userInfo: userInfo)
    }
    
    public init() {}
    
    open func encode<T : Encodable>(_ value: T) throws -> Data {
        
        let encoder = _MessagePackEncoder(options: options)
        
        guard let topLevel = try encoder.box_(value) else {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: [], debugDescription: "Top-level \(T.self) did not encode any values."))
        }
        
        let data = pack(topLevel.messagePackValue)
        return data
    }
}

// MARK: _MessagePackEncoder

fileprivate class _MessagePackEncoder : Encoder {
    
    fileprivate var storage: _MessagePackEncodingStorage
    
    fileprivate let options: MessagePackEncoder._Options
    
    public var codingPath: [CodingKey]
    
    public var userInfo: [CodingUserInfoKey : Any] {
        return self.options.userInfo
    }
    
    fileprivate init(options: MessagePackEncoder._Options, codingPath: [CodingKey] = []) {
        self.options = options
        self.storage = _MessagePackEncodingStorage()
        self.codingPath = codingPath
    }
    
    fileprivate var canEncodeNewValue: Bool {
        return self.storage.count == self.codingPath.count
    }
    
    public func container<Key>(keyedBy: Key.Type) -> KeyedEncodingContainer<Key> {
        
        let topContainer: _MessagePackDictionaryBox
        if canEncodeNewValue {
            topContainer = storage.pushKeyedContainer()
        } else {
            guard let container = storage.containers.last as? _MessagePackDictionaryBox else {
                preconditionFailure("Attempt to push new keyed encoding container when already previously encoded at this path.")
            }
            
            topContainer = container
        }
        
        let container = _MessagePackKeyedEncodingContainer<Key>(referencing: self, codingPath: codingPath, wrapping: topContainer)
        return KeyedEncodingContainer(container)
    }
    
    public func unkeyedContainer() -> UnkeyedEncodingContainer {
        
        let topContainer: _MessagePackArrayBox
        if canEncodeNewValue {
            topContainer = storage.pushUnkeyedContainer()
        } else {
            guard let container = storage.containers.last as? _MessagePackArrayBox else {
                preconditionFailure("Attempt to push new unkeyed encoding container when already previously encoded at this path.")
            }
            
            topContainer = container
        }
        
        return _MessagePackUnkeyedEncodingContainer(referencing: self, codingPath: codingPath, wrapping: topContainer)
    }
    
    public func singleValueContainer() -> SingleValueEncodingContainer {
        return self
    }
}

// MARK: Encoding Storage

fileprivate struct _MessagePackEncodingStorage {
    
    private(set) fileprivate var containers: [_MessagePackBox] = []
    
    fileprivate init() {}
    
    fileprivate var count: Int {
        return self.containers.count
    }
    
    fileprivate mutating func pushKeyedContainer() -> _MessagePackDictionaryBox {
        let dictionary = _MessagePackDictionaryBox()
        containers.append(dictionary)
        return dictionary
    }
    
    fileprivate mutating func pushUnkeyedContainer() -> _MessagePackArrayBox {
        let array = _MessagePackArrayBox()
        containers.append(array)
        return array
    }
    
    fileprivate mutating func push(container: _MessagePackBox) {
        self.containers.append(container)
    }
    
    fileprivate mutating func popContainer() -> _MessagePackBox {
        precondition(containers.count > 0, "Empty container stack.")
        return containers.popLast()!
    }
}

// MARK: Encoding Containers

fileprivate struct _MessagePackKeyedEncodingContainer<K : CodingKey> : KeyedEncodingContainerProtocol {
    typealias Key = K
    
    private let encoder: _MessagePackEncoder
    
    private let container: _MessagePackDictionaryBox
    
    private(set) public var codingPath: [CodingKey]
    
    fileprivate init(referencing encoder: _MessagePackEncoder, codingPath: [CodingKey], wrapping container: _MessagePackDictionaryBox) {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }
    
    public mutating func encodeNil(forKey key: Key)               throws { container.dictionary[key.stringValue] = encoder.boxNil() }
    public mutating func encode(_ value: Bool, forKey key: Key)   throws { container.dictionary[key.stringValue] = encoder.box(value) }
    public mutating func encode(_ value: Int, forKey key: Key)    throws { container.dictionary[key.stringValue] = encoder.box(value) }
    public mutating func encode(_ value: Int8, forKey key: Key)   throws { container.dictionary[key.stringValue] = encoder.box(value) }
    public mutating func encode(_ value: Int16, forKey key: Key)  throws { container.dictionary[key.stringValue] = encoder.box(value) }
    public mutating func encode(_ value: Int32, forKey key: Key)  throws { container.dictionary[key.stringValue] = encoder.box(value) }
    public mutating func encode(_ value: Int64, forKey key: Key)  throws { container.dictionary[key.stringValue] = encoder.box(value) }
    public mutating func encode(_ value: UInt, forKey key: Key)   throws { container.dictionary[key.stringValue] = encoder.box(value) }
    public mutating func encode(_ value: UInt8, forKey key: Key)  throws { container.dictionary[key.stringValue] = encoder.box(value) }
    public mutating func encode(_ value: UInt16, forKey key: Key) throws { container.dictionary[key.stringValue] = encoder.box(value) }
    public mutating func encode(_ value: UInt32, forKey key: Key) throws { container.dictionary[key.stringValue] = encoder.box(value) }
    public mutating func encode(_ value: UInt64, forKey key: Key) throws { container.dictionary[key.stringValue] = encoder.box(value) }
    public mutating func encode(_ value: Float, forKey key: Key)  throws { container.dictionary[key.stringValue] = encoder.box(value) }
    public mutating func encode(_ value: Double, forKey key: Key) throws { container.dictionary[key.stringValue] = encoder.box(value) }
    public mutating func encode(_ value: String, forKey key: Key) throws { container.dictionary[key.stringValue] = encoder.box(value) }
    
    public mutating func encode<T : Encodable>(_ value: T, forKey key: Key) throws {
        encoder.codingPath.append(key)
        defer { encoder.codingPath.removeLast() }
        
        container.dictionary[key.stringValue] = try encoder.box(value)
    }
    
    public mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
        let dictionary = _MessagePackDictionaryBox()
        self.container.dictionary[key.stringValue] = dictionary
        
        codingPath.append(key)
        defer { codingPath.removeLast() }
        
        let container = _MessagePackKeyedEncodingContainer<NestedKey>(referencing: encoder, codingPath: codingPath, wrapping: dictionary)
        return KeyedEncodingContainer(container)
    }
    
    public mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let array = _MessagePackArrayBox()
        container.dictionary[key.stringValue] = array
        
        codingPath.append(key)
        defer { codingPath.removeLast() }
        
        return _MessagePackUnkeyedEncodingContainer(referencing: encoder, codingPath: codingPath, wrapping: array)
    }
    
    public mutating func superEncoder() -> Encoder {
        return _MessagePackReferencingEncoder(referencing: encoder, at: _MessagePackKey.super, wrapping: container)
    }
    
    public mutating func superEncoder(forKey key: Key) -> Encoder {
        return _MessagePackReferencingEncoder(referencing: encoder, at: key, wrapping: container)
    }
}

fileprivate struct _MessagePackUnkeyedEncodingContainer : UnkeyedEncodingContainer {
    
    private let encoder: _MessagePackEncoder
    
    private let container: _MessagePackArrayBox
    
    private(set) public var codingPath: [CodingKey]
    
    public var count: Int {
        return container.array.count
    }
    
    fileprivate init(referencing encoder: _MessagePackEncoder, codingPath: [CodingKey], wrapping container: _MessagePackArrayBox) {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }
    
    public mutating func encodeNil()             throws { container.array.append(encoder.boxNil()) }
    public mutating func encode(_ value: Bool)   throws { container.array.append(encoder.box(value)) }
    public mutating func encode(_ value: Int)    throws { container.array.append(encoder.box(value)) }
    public mutating func encode(_ value: Int8)   throws { container.array.append(encoder.box(value)) }
    public mutating func encode(_ value: Int16)  throws { container.array.append(encoder.box(value)) }
    public mutating func encode(_ value: Int32)  throws { container.array.append(encoder.box(value)) }
    public mutating func encode(_ value: Int64)  throws { container.array.append(encoder.box(value)) }
    public mutating func encode(_ value: UInt)   throws { container.array.append(encoder.box(value)) }
    public mutating func encode(_ value: UInt8)  throws { container.array.append(encoder.box(value)) }
    public mutating func encode(_ value: UInt16) throws { container.array.append(encoder.box(value)) }
    public mutating func encode(_ value: UInt32) throws { container.array.append(encoder.box(value)) }
    public mutating func encode(_ value: UInt64) throws { container.array.append(encoder.box(value)) }
    public mutating func encode(_ value: Float)  throws { container.array.append(encoder.box(value)) }
    public mutating func encode(_ value: Double) throws { container.array.append(encoder.box(value)) }
    public mutating func encode(_ value: String) throws { container.array.append(encoder.box(value)) }
    
    public mutating func encode<T : Encodable>(_ value: T) throws {
        encoder.codingPath.append(_MessagePackKey(index: count))
        defer { encoder.codingPath.removeLast() }
        
        container.array.append(try encoder.box(value))
    }
    
    public mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> {
        codingPath.append(_MessagePackKey(index: count))
        defer { codingPath.removeLast() }
        
        let dictionary = _MessagePackDictionaryBox()
        self.container.array.append(dictionary)
        
        let container = _MessagePackKeyedEncodingContainer<NestedKey>(referencing: encoder, codingPath: codingPath, wrapping: dictionary)
        return KeyedEncodingContainer(container)
    }
    
    public mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        codingPath.append(_MessagePackKey(index: count))
        defer { codingPath.removeLast() }
        
        let array = _MessagePackArrayBox()
        container.array.append(array)
        return _MessagePackUnkeyedEncodingContainer(referencing: encoder, codingPath: codingPath, wrapping: array)
    }
    
    public mutating func superEncoder() -> Encoder {
        return _MessagePackReferencingEncoder(referencing: encoder, at: container.array.count, wrapping: container)
    }
}

extension _MessagePackEncoder : SingleValueEncodingContainer {
    
    fileprivate func assertCanEncodeNewValue() {
        precondition(canEncodeNewValue, "Attempt to encode value through single value container when previously value already encoded.")
    }
    
    public func encodeNil() throws {
        assertCanEncodeNewValue()
        storage.push(container: boxNil())
    }
    
    public func encode(_ value: Bool) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    public func encode(_ value: Int) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    public func encode(_ value: Int8) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    public func encode(_ value: Int16) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    public func encode(_ value: Int32) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    public func encode(_ value: Int64) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    public func encode(_ value: UInt) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    public func encode(_ value: UInt8) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    public func encode(_ value: UInt16) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    public func encode(_ value: UInt32) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    public func encode(_ value: UInt64) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    public func encode(_ value: String) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    public func encode(_ value: Float) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    public func encode(_ value: Double) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    public func encode<T : Encodable>(_ value: T) throws {
        assertCanEncodeNewValue()
        try storage.push(container: box(value))
    }
}

// MARK: Concrete Value Representations

extension _MessagePackEncoder {
    
    fileprivate func boxNil()             -> _MessagePackBox { return _MessagePackValueBox(MessagePackValue()) }
    fileprivate func box(_ value: Bool)   -> _MessagePackBox { return _MessagePackValueBox(MessagePackValue(value)) }
    fileprivate func box(_ value: Int)    -> _MessagePackBox { return _MessagePackValueBox(MessagePackValue(value)) }
    fileprivate func box(_ value: Int8)   -> _MessagePackBox { return _MessagePackValueBox(MessagePackValue(value)) }
    fileprivate func box(_ value: Int16)  -> _MessagePackBox { return _MessagePackValueBox(MessagePackValue(value)) }
    fileprivate func box(_ value: Int32)  -> _MessagePackBox { return _MessagePackValueBox(MessagePackValue(value)) }
    fileprivate func box(_ value: Int64)  -> _MessagePackBox { return _MessagePackValueBox(MessagePackValue(value)) }
    fileprivate func box(_ value: UInt)   -> _MessagePackBox { return _MessagePackValueBox(MessagePackValue(value)) }
    fileprivate func box(_ value: UInt8)  -> _MessagePackBox { return _MessagePackValueBox(MessagePackValue(value)) }
    fileprivate func box(_ value: UInt16) -> _MessagePackBox { return _MessagePackValueBox(MessagePackValue(value)) }
    fileprivate func box(_ value: UInt32) -> _MessagePackBox { return _MessagePackValueBox(MessagePackValue(value)) }
    fileprivate func box(_ value: UInt64) -> _MessagePackBox { return _MessagePackValueBox(MessagePackValue(value)) }
    fileprivate func box(_ value: Float)  -> _MessagePackBox { return _MessagePackValueBox(MessagePackValue(value)) }
    fileprivate func box(_ value: Double) -> _MessagePackBox { return _MessagePackValueBox(MessagePackValue(value)) }
    fileprivate func box(_ value: String) -> _MessagePackBox { return _MessagePackValueBox(MessagePackValue(value)) }
    fileprivate func box(_ value: Data)   -> _MessagePackBox { return _MessagePackValueBox(MessagePackValue(value)) }
    
    fileprivate func box<T : Encodable>(_ value: T) throws -> _MessagePackBox {
        return try box_(value) ?? _MessagePackDictionaryBox()
    }
    
    fileprivate func box_<T : Encodable>(_ value: T) throws -> _MessagePackBox? {
        
        if T.self == Data.self || T.self == NSData.self {
            return box((value as! Data))
        }
        
        let depth = storage.count
        try value.encode(to: self)
        
        guard storage.count > depth else {
            return nil
        }
        
        return storage.popContainer()
    }
}

// MARK: _MessagePackReferencingEncoder

fileprivate class _MessagePackReferencingEncoder : _MessagePackEncoder {
    
    private enum Reference {
        case array(_MessagePackArrayBox, Int)
        case dictionary(_MessagePackDictionaryBox, String)
    }
    
    fileprivate let encoder: _MessagePackEncoder
    
    private let reference: Reference
    
    fileprivate init(referencing encoder: _MessagePackEncoder, at index: Int, wrapping array: _MessagePackArrayBox) {
        self.encoder = encoder
        self.reference = .array(array, index)
        super.init(options: encoder.options, codingPath: encoder.codingPath)
        
        codingPath.append(_MessagePackKey(index: index))
    }
    
    fileprivate init(referencing encoder: _MessagePackEncoder, at key: CodingKey, wrapping dictionary: _MessagePackDictionaryBox) {
        self.encoder = encoder
        self.reference = .dictionary(dictionary, key.stringValue)
        super.init(options: encoder.options, codingPath: encoder.codingPath)
        
        codingPath.append(key)
    }
    
    fileprivate override var canEncodeNewValue: Bool {
        return storage.count == codingPath.count - encoder.codingPath.count - 1
    }
    
    deinit {
        let value: _MessagePackBox
        switch self.storage.count {
        case 0: value = _MessagePackDictionaryBox()
        case 1: value = storage.popContainer()
        default: fatalError("Referencing encoder deallocated with multiple containers on stack.")
        }
        
        switch self.reference {
        case .array(let box, let index):
            box.array.insert(value, at: index)
            
        case .dictionary(let box, let key):
            box.dictionary[key] = value
        }
    }
}

// MARK: - Message Pack Decoder
open class MessagePackDecoder {
    
    open var userInfo: [CodingUserInfoKey : Any] = [:]
    
    fileprivate struct _Options {
        let userInfo: [CodingUserInfoKey : Any]
    }
    
    fileprivate var options: _Options {
        return _Options(userInfo: userInfo)
    }
    
    public init() {}
    
    open func decode<T : Decodable>(_ type: T.Type, from data: Data) throws -> T {
        
        let topLevel: MessagePackValue
        do {
            topLevel = try unpackFirst(data)
        } catch {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "The given data was not valid Message Pack.", underlyingError: error))
        }
        
        let decoder = _MessagePackDecoder(referencing: topLevel, options: options)
        
        guard let value = try decoder.unbox(topLevel, as: T.self) else {
            throw DecodingError.valueNotFound(T.self, DecodingError.Context(codingPath: [], debugDescription: "The given data did not contain a top-level value."))
        }
        
        return value
    }
}

// MARK: _MessagePackDecoder

fileprivate class _MessagePackDecoder : Decoder {
    
    fileprivate var storage: _MessagePackDecodingStorage
    
    fileprivate let options: MessagePackDecoder._Options
    
    fileprivate(set) public var codingPath: [CodingKey]
    
    public var userInfo: [CodingUserInfoKey : Any] {
        return options.userInfo
    }
    
    fileprivate init(referencing container: MessagePackValue, at codingPath: [CodingKey] = [], options: MessagePackDecoder._Options) {
        self.storage = _MessagePackDecodingStorage()
        self.storage.push(container: container)
        self.codingPath = codingPath
        self.options = options
    }
    
    public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        
        guard let messagePackDictionary = storage.topContainer.dictionaryValue else {
            let description = "Expected to decode dictionary but found \(storage.topContainer)"
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: description)
            throw DecodingError.typeMismatch([MessagePackValue: MessagePackValue].self, context)
        }
        
        var dictionary: [String: MessagePackValue] = [:]
        try messagePackDictionary.forEach { (key, value) in
            
            guard let keyString = key.stringValue else {
                let description = "Expected to decode string but found \(key)"
                let context = DecodingError.Context(codingPath: codingPath, debugDescription: description)
                throw DecodingError.typeMismatch(String.self, context)
            }
            
            dictionary[keyString] = value
        }
        
        let container = _MessagePackKeyedDecodingContainer<Key>(referencing: self, wrapping: dictionary)
        return KeyedDecodingContainer(container)
    }
    
    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        
        guard let array = storage.topContainer.arrayValue else {
            let description = "Expected to decode array but found \(storage.topContainer)"
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: description)
            throw DecodingError.typeMismatch([MessagePackValue].self, context)
        }
        
        return _MessagePackUnkeyedDecodingContainer(referencing: self, wrapping: array)
    }
    
    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        return self
    }
}

// MARK: Decoding Storage

fileprivate struct _MessagePackDecodingStorage {
    
    private(set) fileprivate var containers: [MessagePackValue] = []
    
    fileprivate init() {}
    
    fileprivate var count: Int {
        return containers.count
    }
    
    fileprivate var topContainer: MessagePackValue {
        precondition(containers.count > 0, "Empty container stack.")
        return containers.last!
    }
    
    fileprivate mutating func push(container: MessagePackValue) {
        containers.append(container)
    }
    
    fileprivate mutating func popContainer() {
        precondition(containers.count > 0, "Empty container stack.")
        containers.removeLast()
    }
}

// MARK: Decoding Containers

fileprivate struct _MessagePackKeyedDecodingContainer<K : CodingKey> : KeyedDecodingContainerProtocol {
    typealias Key = K
    
    private let decoder: _MessagePackDecoder
    
    private let container: [String: MessagePackValue]
    
    private(set) public var codingPath: [CodingKey]
    
    fileprivate init(referencing decoder: _MessagePackDecoder, wrapping container: [String: MessagePackValue]) {
        self.decoder = decoder
        self.container = container
        self.codingPath = decoder.codingPath
    }
    
    public var allKeys: [Key] {
        return container.keys.flatMap { Key(stringValue: $0) }
    }
    
    public func contains(_ key: Key) -> Bool {
        return container[key.stringValue] != nil
    }
    
    public func decodeNil(forKey key: Key) throws -> Bool {
        guard let entry = container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }
        
        return entry.isNil
    }
    
    public func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }
        
        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }
        
        guard let value = try self.decoder.unbox(entry, as: Bool.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    public func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }
        
        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }
        
        guard let value = try self.decoder.unbox(entry, as: Int.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    public func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }
        
        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }
        
        guard let value = try self.decoder.unbox(entry, as: Int8.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    public func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }
        
        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }
        
        guard let value = try self.decoder.unbox(entry, as: Int16.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    public func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }
        
        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }
        
        guard let value = try self.decoder.unbox(entry, as: Int32.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    public func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }
        
        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }
        
        guard let value = try self.decoder.unbox(entry, as: Int64.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    public func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }
        
        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }
        
        guard let value = try self.decoder.unbox(entry, as: UInt.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    public func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }
        
        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }
        
        guard let value = try self.decoder.unbox(entry, as: UInt8.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    public func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }
        
        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }
        
        guard let value = try self.decoder.unbox(entry, as: UInt16.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    public func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }
        
        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }
        
        guard let value = try self.decoder.unbox(entry, as: UInt32.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    public func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }
        
        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }
        
        guard let value = try self.decoder.unbox(entry, as: UInt64.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    public func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }
        
        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }
        
        guard let value = try self.decoder.unbox(entry, as: Float.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    public func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }
        
        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }
        
        guard let value = try self.decoder.unbox(entry, as: Double.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    public func decode(_ type: String.Type, forKey key: Key) throws -> String {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }
        
        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }
        
        guard let value = try self.decoder.unbox(entry, as: String.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    public func decode<T : Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
        guard let entry = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }
        
        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }
        
        guard let value = try self.decoder.unbox(entry, as: T.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    public func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> {
        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }
        
        guard let value = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(key,
                                            DecodingError.Context(codingPath: self.codingPath,
                                                                  debugDescription: "Cannot get \(KeyedDecodingContainer<NestedKey>.self) -- no value found for key \"\(key.stringValue)\""))
        }
        
        guard let messagePackDictionary = value.dictionaryValue else {
            let description = "Expected to decode dictionary but found \(value)"
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: description)
            throw DecodingError.typeMismatch([MessagePackValue: MessagePackValue].self, context)
        }
        
        var dictionary: [String: MessagePackValue] = [:]
        try messagePackDictionary.forEach { (key, value) in
            
            guard let keyString = key.stringValue else {
                let description = "Expected to decode string but found \(key)"
                let context = DecodingError.Context(codingPath: codingPath, debugDescription: description)
                throw DecodingError.typeMismatch(String.self, context)
            }
            
            dictionary[keyString] = value
        }
        
        let container = _MessagePackKeyedDecodingContainer<NestedKey>(referencing: decoder, wrapping: dictionary)
        return KeyedDecodingContainer(container)
    }
    
    public func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }
        
        guard let value = container[key.stringValue] else {
            throw DecodingError.keyNotFound(key,
                                            DecodingError.Context(codingPath: self.codingPath,
                                                                  debugDescription: "Cannot get UnkeyedDecodingContainer -- no value found for key \"\(key.stringValue)\""))
        }
        
        guard let array = value.arrayValue else {
            let description = "Expected to decode array but found \(value)"
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: description)
            throw DecodingError.typeMismatch([MessagePackValue].self, context)
        }
        
        return _MessagePackUnkeyedDecodingContainer(referencing: decoder, wrapping: array)
    }
    
    private func _superDecoder(forKey key: CodingKey) throws -> Decoder {
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }
        
        let value: MessagePackValue = container[key.stringValue] ?? .nil
        return _MessagePackDecoder(referencing: value, at: decoder.codingPath, options: decoder.options)
    }
    
    public func superDecoder() throws -> Decoder {
        return try _superDecoder(forKey: _MessagePackKey.super)
    }
    
    public func superDecoder(forKey key: Key) throws -> Decoder {
        return try _superDecoder(forKey: key)
    }
}

fileprivate struct _MessagePackUnkeyedDecodingContainer : UnkeyedDecodingContainer {
    
    private let decoder: _MessagePackDecoder
    
    private let container: [MessagePackValue]
    
    private(set) public var codingPath: [CodingKey]
    
    private(set) public var currentIndex: Int
    
    fileprivate init(referencing decoder: _MessagePackDecoder, wrapping container: [MessagePackValue]) {
        self.decoder = decoder
        self.container = container
        self.codingPath = decoder.codingPath
        self.currentIndex = 0
    }
    
    public var count: Int? {
        return container.count
    }
    
    public var isAtEnd: Bool {
        return currentIndex >= count!
    }
    
    private func expectNotAtEnd(type: Any.Type) throws {
        guard !isAtEnd else {
            let path = decoder.codingPath + [_MessagePackKey(index: currentIndex)]
            let context = DecodingError.Context(codingPath: path, debugDescription: "Unkeyed container is at end.")
            throw DecodingError.valueNotFound(type, context)
        }
    }
    
    public mutating func decodeNil() throws -> Bool {
        try expectNotAtEnd(type: Any?.self)
        
        if container[currentIndex].isNil {
            self.currentIndex += 1
            return true
        } else {
            return false
        }
    }
    
    public mutating func decode(_ type: Bool.Type) throws -> Bool {
        try expectNotAtEnd(type: type)
        
        self.decoder.codingPath.append(_MessagePackKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }
        
        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Bool.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_MessagePackKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }
        
        self.currentIndex += 1
        return decoded
    }
    
    public mutating func decode(_ type: Int.Type) throws -> Int {
        try expectNotAtEnd(type: type)
        
        self.decoder.codingPath.append(_MessagePackKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }
        
        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Int.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_MessagePackKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }
        
        self.currentIndex += 1
        return decoded
    }
    
    public mutating func decode(_ type: Int8.Type) throws -> Int8 {
        try expectNotAtEnd(type: type)
        
        self.decoder.codingPath.append(_MessagePackKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }
        
        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Int8.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_MessagePackKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }
        
        self.currentIndex += 1
        return decoded
    }
    
    public mutating func decode(_ type: Int16.Type) throws -> Int16 {
        try expectNotAtEnd(type: type)
        
        self.decoder.codingPath.append(_MessagePackKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }
        
        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Int16.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_MessagePackKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }
        
        self.currentIndex += 1
        return decoded
    }
    
    public mutating func decode(_ type: Int32.Type) throws -> Int32 {
        try expectNotAtEnd(type: type)
        
        self.decoder.codingPath.append(_MessagePackKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }
        
        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Int32.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_MessagePackKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }
        
        self.currentIndex += 1
        return decoded
    }
    
    public mutating func decode(_ type: Int64.Type) throws -> Int64 {
        try expectNotAtEnd(type: type)
        
        self.decoder.codingPath.append(_MessagePackKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }
        
        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Int64.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_MessagePackKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }
        
        self.currentIndex += 1
        return decoded
    }
    
    public mutating func decode(_ type: UInt.Type) throws -> UInt {
        try expectNotAtEnd(type: type)
        
        self.decoder.codingPath.append(_MessagePackKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }
        
        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: UInt.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_MessagePackKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }
        
        self.currentIndex += 1
        return decoded
    }
    
    public mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
        try expectNotAtEnd(type: type)
        
        self.decoder.codingPath.append(_MessagePackKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }
        
        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: UInt8.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_MessagePackKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }
        
        self.currentIndex += 1
        return decoded
    }
    
    public mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
        try expectNotAtEnd(type: type)
        
        self.decoder.codingPath.append(_MessagePackKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }
        
        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: UInt16.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_MessagePackKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }
        
        self.currentIndex += 1
        return decoded
    }
    
    public mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        try expectNotAtEnd(type: type)
        
        self.decoder.codingPath.append(_MessagePackKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }
        
        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: UInt32.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_MessagePackKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }
        
        self.currentIndex += 1
        return decoded
    }
    
    public mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        try expectNotAtEnd(type: type)
        
        self.decoder.codingPath.append(_MessagePackKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }
        
        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: UInt64.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_MessagePackKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }
        
        self.currentIndex += 1
        return decoded
    }
    
    public mutating func decode(_ type: Float.Type) throws -> Float {
        try expectNotAtEnd(type: type)
        
        self.decoder.codingPath.append(_MessagePackKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }
        
        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Float.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_MessagePackKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }
        
        self.currentIndex += 1
        return decoded
    }
    
    public mutating func decode(_ type: Double.Type) throws -> Double {
        try expectNotAtEnd(type: type)
        
        self.decoder.codingPath.append(_MessagePackKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }
        
        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Double.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_MessagePackKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }
        
        self.currentIndex += 1
        return decoded
    }
    
    public mutating func decode(_ type: String.Type) throws -> String {
        try expectNotAtEnd(type: type)
        
        self.decoder.codingPath.append(_MessagePackKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }
        
        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: String.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_MessagePackKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }
        
        self.currentIndex += 1
        return decoded
    }
    
    public mutating func decode<T : Decodable>(_ type: T.Type) throws -> T {
        try expectNotAtEnd(type: type)
        
        self.decoder.codingPath.append(_MessagePackKey(index: currentIndex))
        defer { self.decoder.codingPath.removeLast() }
        
        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: T.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_MessagePackKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
        }
        
        self.currentIndex += 1
        return decoded
    }
    
    public mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> {
        decoder.codingPath.append(_MessagePackKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }
        
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(KeyedDecodingContainer<NestedKey>.self,
                                              DecodingError.Context(codingPath: self.codingPath,
                                                                    debugDescription: "Cannot get nested keyed container -- unkeyed container is at end."))
        }
        
        let value = self.container[currentIndex]
        
        guard let messagePackDictionary = value.dictionaryValue else {
            let description = "Cannot get keyed decoding container -- found \(value) instead"
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: description)
            throw DecodingError.typeMismatch([MessagePackValue: MessagePackValue].self, context)
        }
        
        var dictionary: [String: MessagePackValue] = [:]
        try messagePackDictionary.forEach { (key, value) in
            
            guard let keyString = key.stringValue else {
                let description = "Expected to decode string but found \(key)"
                let context = DecodingError.Context(codingPath: codingPath, debugDescription: description)
                throw DecodingError.typeMismatch(String.self, context)
            }
            
            dictionary[keyString] = value
        }
        
        self.currentIndex += 1
        let container = _MessagePackKeyedDecodingContainer<NestedKey>(referencing: decoder, wrapping: dictionary)
        return KeyedDecodingContainer(container)
    }
    
    public mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        self.decoder.codingPath.append(_MessagePackKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }
        
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self,
                                              DecodingError.Context(codingPath: self.codingPath,
                                                                    debugDescription: "Cannot get nested keyed container -- unkeyed container is at end."))
        }
        
        let value = self.container[self.currentIndex]
        guard let array = value.arrayValue else {
            let description = "Expected to decode array but found \(value)"
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: description)
            throw DecodingError.typeMismatch([MessagePackValue].self, context)
        }
        
        self.currentIndex += 1
        return _MessagePackUnkeyedDecodingContainer(referencing: decoder, wrapping: array)
    }
    
    public mutating func superDecoder() throws -> Decoder {
        self.decoder.codingPath.append(_MessagePackKey(index: self.currentIndex))
        defer { self.decoder.codingPath.removeLast() }
        
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(Decoder.self,
                                              DecodingError.Context(codingPath: self.codingPath,
                                                                    debugDescription: "Cannot get superDecoder() -- unkeyed container is at end."))
        }
        
        let value = self.container[self.currentIndex]
        self.currentIndex += 1
        return _MessagePackDecoder(referencing: value, at: decoder.codingPath, options: decoder.options)
    }
}

extension _MessagePackDecoder : SingleValueDecodingContainer {
    
    public func decodeNil() -> Bool {
        return self.storage.topContainer.isNil
    }
    
    public func decode(_ type: Bool.Type) throws -> Bool {
        return try unbox(storage.topContainer, as: Bool.self)!
    }
    
    public func decode(_ type: Int.Type) throws -> Int {
        return try unbox(storage.topContainer, as: Int.self)!
    }
    
    public func decode(_ type: Int8.Type) throws -> Int8 {
        return try unbox(storage.topContainer, as: Int8.self)!
    }
    
    public func decode(_ type: Int16.Type) throws -> Int16 {
        return try unbox(storage.topContainer, as: Int16.self)!
    }
    
    public func decode(_ type: Int32.Type) throws -> Int32 {
        return try unbox(storage.topContainer, as: Int32.self)!
    }
    
    public func decode(_ type: Int64.Type) throws -> Int64 {
        return try unbox(storage.topContainer, as: Int64.self)!
    }
    
    public func decode(_ type: UInt.Type) throws -> UInt {
        return try unbox(storage.topContainer, as: UInt.self)!
    }
    
    public func decode(_ type: UInt8.Type) throws -> UInt8 {
        return try unbox(storage.topContainer, as: UInt8.self)!
    }
    
    public func decode(_ type: UInt16.Type) throws -> UInt16 {
        return try unbox(storage.topContainer, as: UInt16.self)!
    }
    
    public func decode(_ type: UInt32.Type) throws -> UInt32 {
        return try unbox(storage.topContainer, as: UInt32.self)!
    }
    
    public func decode(_ type: UInt64.Type) throws -> UInt64 {
        return try unbox(storage.topContainer, as: UInt64.self)!
    }
    
    public func decode(_ type: Float.Type) throws -> Float {
        return try unbox(storage.topContainer, as: Float.self)!
    }
    
    public func decode(_ type: Double.Type) throws -> Double {
        return try unbox(storage.topContainer, as: Double.self)!
    }
    
    public func decode(_ type: String.Type) throws -> String {
        return try unbox(storage.topContainer, as: String.self)!
    }
    
    public func decode<T : Decodable>(_ type: T.Type) throws -> T {
        return try unbox(storage.topContainer, as: T.self)!
    }
}

// MARK: Concrete Value Representations

extension _MessagePackDecoder {
    
    fileprivate func unbox(_ value: MessagePackValue, as type: Bool.Type) throws -> Bool? {
        return value.boolValue
    }
    
    fileprivate func unbox(_ value: MessagePackValue, as type: Int.Type) throws -> Int? {
        return value.integerValue.map { Int($0) }
    }
    
    fileprivate func unbox(_ value: MessagePackValue, as type: Int8.Type) throws -> Int8? {
        return value.integerValue.map { Int8($0) }
    }
    
    fileprivate func unbox(_ value: MessagePackValue, as type: Int16.Type) throws -> Int16? {
        return value.integerValue.map { Int16($0) }
    }
    
    fileprivate func unbox(_ value: MessagePackValue, as type: Int32.Type) throws -> Int32? {
        return value.integerValue.map { Int32($0) }
    }
    
    fileprivate func unbox(_ value: MessagePackValue, as type: Int64.Type) throws -> Int64? {
        return value.integerValue.map { Int64($0) }
    }
    
    fileprivate func unbox(_ value: MessagePackValue, as type: UInt.Type) throws -> UInt? {
        return value.unsignedIntegerValue.map { UInt($0) }
    }
    
    fileprivate func unbox(_ value: MessagePackValue, as type: UInt8.Type) throws -> UInt8? {
        return value.unsignedIntegerValue.map { UInt8($0) }
    }
    
    fileprivate func unbox(_ value: MessagePackValue, as type: UInt16.Type) throws -> UInt16? {
        return value.unsignedIntegerValue.map { UInt16($0) }
    }
    
    fileprivate func unbox(_ value: MessagePackValue, as type: UInt32.Type) throws -> UInt32? {
        return value.unsignedIntegerValue.map { UInt32($0) }
    }
    
    fileprivate func unbox(_ value: MessagePackValue, as type: UInt64.Type) throws -> UInt64? {
        return value.unsignedIntegerValue.map { UInt64($0) }
    }
    
    fileprivate func unbox(_ value: MessagePackValue, as type: Float.Type) throws -> Float? {
        return value.floatValue
    }
    
    fileprivate func unbox(_ value: MessagePackValue, as type: Double.Type) throws -> Double? {
        return value.doubleValue
    }
    
    fileprivate func unbox(_ value: MessagePackValue, as type: String.Type) throws -> String? {
        return value.stringValue
    }
    
    fileprivate func unbox(_ value: MessagePackValue, as type: Data.Type) throws -> Data? {
        return value.dataValue
    }
    
    fileprivate func unbox<T : Decodable>(_ value: MessagePackValue, as type: T.Type) throws -> T? {
        let decoded: T
        if T.self == Data.self || T.self == NSData.self {
            guard let data = try unbox(value, as: Data.self) else { return nil }
            decoded = data as! T
        } else {
            storage.push(container: value)
            decoded = try T(from: self)
            storage.popContainer()
        }
        
        return decoded
    }
}

// MARK: - Shared Key Types

fileprivate struct _MessagePackKey : CodingKey {
    public var stringValue: String
    public var intValue: Int?
    
    public init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
    
    public init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
    
    fileprivate init(index: Int) {
        self.stringValue = "Index \(index)"
        self.intValue = index
    }
    
    fileprivate static let `super` = _MessagePackKey(stringValue: "super")!
}


// MARK: - Box

fileprivate protocol _MessagePackBox {
    var messagePackValue: MessagePackValue { get }
}

fileprivate class _MessagePackValueBox: _MessagePackBox {
    var messagePackValue: MessagePackValue
    
    init(_ messagePackValue: MessagePackValue) {
        self.messagePackValue = messagePackValue
    }
}

fileprivate class _MessagePackDictionaryBox: _MessagePackBox {
    var dictionary: [String: _MessagePackBox] = [:]
    
    var messagePackValue: MessagePackValue {
        var valueMap: [MessagePackValue: MessagePackValue] = [:]
        dictionary.forEach { valueMap[.string($0)] = $1.messagePackValue }
        return .map(valueMap)
    }
}

fileprivate class _MessagePackArrayBox: _MessagePackBox {
    var array: [_MessagePackBox] = []
    
    var messagePackValue: MessagePackValue {
        let valueArray = array.map { $0.messagePackValue }
        return .array(valueArray)
    }
}

