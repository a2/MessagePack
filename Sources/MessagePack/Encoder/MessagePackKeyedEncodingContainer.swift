//
//  MessagePackKeyedEncodingContainer.swift
//  MessagePack
//
//  Created by Andrew Eng on 20/2/18.
//

import Foundation

final class MessagePackKeyedEncodingContainer<K: CodingKey> {
    
    fileprivate let storage: MessagePackDictionaryStorage
    fileprivate let options: _MessagePackEncoder.Options
    
    init(storage: MessagePackDictionaryStorage, options: _MessagePackEncoder.Options) {
        self.storage = storage
        self.options = options
    }
}

// MARK: Helper
extension MessagePackKeyedEncodingContainer {
    
    fileprivate func _encode<T: MessagePackRepresentable>(_ value: T, forKey key: K) throws {
        storage[key.stringValue] = value.messagePack
    }
    
    fileprivate func _encodeIfPresent<T: MessagePackRepresentable>(_ value: T?, forKey key: K) throws {
        if options.keyedEncodingOptions.contains(.ignoreKeysWithNilValue) && (value == nil) {
            return
        }
        
        if let value = value {
            try _encode(value, forKey: key)
        } else {
            storage[key.stringValue] = .`nil`
        }
    }
    
    fileprivate func _encodeEncodable<T: Encodable>(_ value: T, forKey key: Key) throws {
        let encoder = _MessagePackEncoder(options: options)
        try value.encode(to: encoder)
        storage[key.stringValue] = encoder.messagePack
    }
    
    fileprivate func _encodeEncodableIfPresent<T: Encodable>(_ value: T?, forKey key: Key) throws {
        if options.keyedEncodingOptions.contains(.ignoreKeysWithNilValue) && (value == nil) {
            return
        }
        
        if let value = value {
            try _encodeEncodable(value, forKey: key)
        } else {
            storage[key.stringValue] = .`nil`
        }
    }
}

// MARK: - KeyedEncodingContainerProtocols
extension MessagePackKeyedEncodingContainer: KeyedEncodingContainerProtocol {
    typealias Key = K
    
    // TODO: Implement Me!
    var codingPath: [CodingKey] { return [] }
    
    func encodeNil(forKey key: Key) throws { storage[key.stringValue] = .`nil` }
    func encode(_ value: Bool, forKey key: Key) throws   { try _encode(value, forKey: key) }
    func encode(_ value: Int, forKey key: Key) throws    { try _encode(value, forKey: key) }
    func encode(_ value: Int8, forKey key: Key) throws   { try _encode(value, forKey: key) }
    func encode(_ value: Int16, forKey key: Key) throws  { try _encode(value, forKey: key) }
    func encode(_ value: Int32, forKey key: Key) throws  { try _encode(value, forKey: key) }
    func encode(_ value: Int64, forKey key: Key) throws  { try _encode(value, forKey: key) }
    func encode(_ value: UInt, forKey key: Key) throws   { try _encode(value, forKey: key) }
    func encode(_ value: UInt8, forKey key: Key) throws  { try _encode(value, forKey: key) }
    func encode(_ value: UInt16, forKey key: Key) throws { try _encode(value, forKey: key) }
    func encode(_ value: UInt32, forKey key: Key) throws { try _encode(value, forKey: key) }
    func encode(_ value: UInt64, forKey key: Key) throws { try _encode(value, forKey: key) }
    func encode(_ value: Float, forKey key: Key) throws  { try _encode(value, forKey: key) }
    func encode(_ value: Double, forKey key: Key) throws { try _encode(value, forKey: key) }
    func encode(_ value: String, forKey key: Key) throws { try _encode(value, forKey: key) }
    
    func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
        
        if T.self == Data.self || T.self == NSData.self {
            try _encode(value as! Data, forKey: key)
        } else {
            try _encodeEncodable(value, forKey: key)
        }
    }
    
    func encodeIfPresent(_ value: Bool?, forKey key: Key) throws   { try _encodeIfPresent(value, forKey: key) }
    func encodeIfPresent(_ value: Int?, forKey key: Key) throws    { try _encodeIfPresent(value, forKey: key) }
    func encodeIfPresent(_ value: Int8?, forKey key: Key) throws   { try _encodeIfPresent(value, forKey: key) }
    func encodeIfPresent(_ value: Int16?, forKey key: Key) throws  { try _encodeIfPresent(value, forKey: key) }
    func encodeIfPresent(_ value: Int32?, forKey key: Key) throws  { try _encodeIfPresent(value, forKey: key) }
    func encodeIfPresent(_ value: Int64?, forKey key: Key) throws  { try _encodeIfPresent(value, forKey: key) }
    func encodeIfPresent(_ value: UInt?, forKey key: Key) throws   { try _encodeIfPresent(value, forKey: key) }
    func encodeIfPresent(_ value: UInt8?, forKey key: Key) throws  { try _encodeIfPresent(value, forKey: key) }
    func encodeIfPresent(_ value: UInt16?, forKey key: Key) throws { try _encodeIfPresent(value, forKey: key) }
    func encodeIfPresent(_ value: UInt32?, forKey key: Key) throws { try _encodeIfPresent(value, forKey: key) }
    func encodeIfPresent(_ value: UInt64?, forKey key: Key) throws { try _encodeIfPresent(value, forKey: key) }
    func encodeIfPresent(_ value: Float?, forKey key: Key) throws  { try _encodeIfPresent(value, forKey: key) }
    func encodeIfPresent(_ value: Double?, forKey key: Key) throws { try _encodeIfPresent(value, forKey: key) }
    func encodeIfPresent(_ value: String?, forKey key: Key) throws { try _encodeIfPresent(value, forKey: key) }

    func encodeIfPresent<T: Encodable>(_ value: T?, forKey key: Key) throws {
        
        if T.self == Data.self || T.self == NSData.self {
            try _encodeIfPresent(value as! Data?, forKey: key)
        } else {
            try _encodeEncodableIfPresent(value, forKey: key)
        }
    }
    
    func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type, forKey key: Key)
        -> KeyedEncodingContainer<NestedKey>
    {
        let storage = MessagePackDictionaryStorage()
        self.storage[key.stringValue] = storage
        let container = MessagePackKeyedEncodingContainer<NestedKey>(storage: storage, options: options)
        return KeyedEncodingContainer(container)
    }
    
    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let storage = MessagePackArrayStorage()
        self.storage[key.stringValue] = storage
        return MessagePackUnkeyedEncodingContainer(storage: storage, options: options)
    }
    
    // TODO: Implement Me!
    func superEncoder() -> Encoder { abort() }
    
    // TODO: Implement Me!
    func superEncoder(forKey key: Key) -> Encoder { abort() }
}
