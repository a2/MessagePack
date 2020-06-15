//
//  MessagePackKeyedDecodingContainer.swift
//  MessagePack
//
//  Created by Andrew Eng on 20/2/18.
//

import Foundation

final class MessagePackKeyedDecodingContainer<K: CodingKey> {
    
    let map: [MessagePackValue: MessagePackValue]
    
    init(map: [MessagePackValue: MessagePackValue]) {
        self.map = map
    }
}

// MARK: - Helper
extension MessagePackKeyedDecodingContainer {
    
    fileprivate func _decode<T: MessagePackRepresentable>(_ type: T.Type, forKey key: Key) throws -> T {
        let value = try valueForKey(key)
        return try _decode(value, type: type)
    }
    
    fileprivate func _decode<T: MessagePackRepresentable>(_ value: MessagePackValue, type: T.Type) throws -> T {
        
        guard let decoded = T(messagePack: value) else {
            let msg = "Cannot decode \(type) from \(value)"
            let context = DecodingError.Context(codingPath: [], debugDescription: msg)
            throw DecodingError.typeMismatch(type, context)
        }
        return decoded
    }
    
    fileprivate func _decodeIfPresent<T: MessagePackRepresentable>(_ type: T.Type, forKey key: Key) throws -> T? {
        
        guard let value = map[.string(key.stringValue)] else {
            return nil
        }
        
        if case .`nil` = value {
            return nil
        } else {
            return try _decode(value, type: type)
        }
    }
    
    fileprivate func _decodeDecodable<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
        let value = try valueForKey(key)
        return try _decodeDecodable(value, type: type)
    }
    
    fileprivate func _decodeDecodable<T: Decodable>(_ value: MessagePackValue, type: T.Type) throws -> T {
        let decoder = _MessagePackDecoder(value: value)
        return try T(from: decoder)
    }
    
    fileprivate func _decodeDecodableIfPresent<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T? {
        
        guard let value = map[.string(key.stringValue)] else {
            return nil
        }
        
        if case .`nil` = value {
            return nil
        } else {
            return try _decodeDecodable(value, type: type)
        }
    }
    
    fileprivate func valueForKey(_ key: Key) throws -> MessagePackValue {
        
        guard let value = map[.string(key.stringValue)] else {
            let msg = "Key not found : \(key)"
            let context = DecodingError.Context(codingPath: [], debugDescription: msg)
            throw DecodingError.keyNotFound(key, context)
        }
        return value
    }
}

// MARK: - KeyedDecodingContainerProtocol
extension MessagePackKeyedDecodingContainer: KeyedDecodingContainerProtocol {
    typealias Key = K
    
    // TODO: Implement Me!
    var codingPath: [CodingKey] { return [] }
    
    var allKeys: [Key] {
        return map.keys.flatMap() {
            guard let stringValue = $0.stringValue else { return nil }
            return Key(stringValue: stringValue)
        }
    }
    
    func contains(_ key: Key) -> Bool {
        return map[.string(key.stringValue)] != nil
    }
    
    func decodeNil(forKey key: Key) throws -> Bool {
        let value = try valueForKey(key)
        return (value == .`nil`)
    }
    
    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool     { return try _decode(type, forKey: key) }
    func decode(_ type: Int.Type, forKey key: Key) throws -> Int       { return try _decode(type, forKey: key) }
    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8     { return try _decode(type, forKey: key) }
    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16   { return try _decode(type, forKey: key) }
    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32   { return try _decode(type, forKey: key) }
    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64   { return try _decode(type, forKey: key) }
    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt     { return try _decode(type, forKey: key) }
    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8   { return try _decode(type, forKey: key) }
    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 { return try _decode(type, forKey: key) }
    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 { return try _decode(type, forKey: key) }
    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 { return try _decode(type, forKey: key) }
    func decode(_ type: Float.Type, forKey key: Key) throws -> Float   { return try _decode(type, forKey: key) }
    func decode(_ type: Double.Type, forKey key: Key) throws -> Double { return try _decode(type, forKey: key) }
    func decode(_ type: String.Type, forKey key: Key) throws -> String { return try _decode(type, forKey: key) }
    
    func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
        
        if T.self == Data.self || T.self == NSData.self {
            return try _decode(Data.self, forKey: key) as! T
        } else {
            return try _decodeDecodable(type, forKey: key)
        }
    }
    
    func decodeIfPresent(_ type: Bool.Type, forKey key: Key) throws -> Bool? {
        return try _decodeIfPresent(type, forKey: key)
    }
    func decodeIfPresent(_ type: Int.Type, forKey key: Key) throws -> Int? {
        return try _decodeIfPresent(type, forKey: key)
    }
    func decodeIfPresent(_ type: Int8.Type, forKey key: Key) throws -> Int8? {
        return try _decodeIfPresent(type, forKey: key)
    }
    func decodeIfPresent(_ type: Int16.Type, forKey key: Key) throws -> Int16? {
        return try _decodeIfPresent(type, forKey: key)
    }
    func decodeIfPresent(_ type: Int32.Type, forKey key: Key) throws -> Int32? {
        return try _decodeIfPresent(type, forKey: key)
    }
    func decodeIfPresent(_ type: Int64.Type, forKey key: Key) throws -> Int64? {
        return try _decodeIfPresent(type, forKey: key)
    }
    func decodeIfPresent(_ type: UInt.Type, forKey key: Key) throws -> UInt? {
        return try _decodeIfPresent(type, forKey: key)
    }
    func decodeIfPresent(_ type: UInt8.Type, forKey key: Key) throws -> UInt8? {
        return try _decodeIfPresent(type, forKey: key)
    }
    func decodeIfPresent(_ type: UInt16.Type, forKey key: Key) throws -> UInt16? {
        return try _decodeIfPresent(type, forKey: key)
    }
    func decodeIfPresent(_ type: UInt32.Type, forKey key: Key) throws -> UInt32? {
        return try _decodeIfPresent(type, forKey: key)
    }
    func decodeIfPresent(_ type: UInt64.Type, forKey key: Key) throws -> UInt64? {
        return try _decodeIfPresent(type, forKey: key)
    }
    func decodeIfPresent(_ type: Float.Type, forKey key: Key) throws -> Float? {
        return try _decodeIfPresent(type, forKey: key)
    }
    func decodeIfPresent(_ type: Double.Type, forKey key: Key) throws -> Double? {
        return try _decodeIfPresent(type, forKey: key)
    }
    func decodeIfPresent(_ type: String.Type, forKey key: Key) throws -> String? {
        return try _decodeIfPresent(type, forKey: key)
    }

    func decodeIfPresent<T : Decodable>(_ type: T.Type, forKey key: K) throws -> T? {
        
        if T.self == Data.self || T.self == NSData.self {
            return try _decodeIfPresent(Data.self, forKey: key) as! T?
        } else {
            return try _decodeDecodableIfPresent(type, forKey: key)
        }
    }
    
    func nestedContainer<NestedKey: CodingKey>(keyedBy type: NestedKey.Type, forKey key: Key)
        throws -> KeyedDecodingContainer<NestedKey>
    {
        let value = try valueForKey(key)

        guard case let .map(map) = value else {
            let msg = "Cannot decode map from \(value)"
            let context = DecodingError.Context(codingPath: [], debugDescription: msg)
            throw DecodingError.typeMismatch([MessagePackValue: MessagePackValue].self, context)
        }
        
        let container = MessagePackKeyedDecodingContainer<NestedKey>(map: map)
        return KeyedDecodingContainer(container)
    }
    
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        let value = try valueForKey(key)

        guard case let .array(array) = value else {
            let msg = "Cannot decode array from \(value)"
            let context = DecodingError.Context(codingPath: [], debugDescription: msg)
            throw DecodingError.typeMismatch([MessagePackValue].self, context)
        }

        return MessagePackUnkeyedDecodingContainer(array: array)
    }
    
    // TODO: Implement Me!
    func superDecoder() throws -> Decoder { abort() }
    
    // TODO: Implement Me!
    func superDecoder(forKey key: Key) throws -> Decoder { abort() }
}
