//
//  MessagePackDecoder.swift
//  MessagePack
//
//  Created by Andrew Eng on 20/2/18.
//

import Foundation

open class MessagePackDecoder {
    public init() {}

    open func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let messagePack = try decodeToMessagePack(from: data)
        return try decodeMessagePack(type, from: messagePack)
    }
    
    open func decodeToMessagePack(from data: Data) throws -> MessagePackValue {
        return try unpackFirst(data)
    }
    
    open func decodeMessagePack<T: Decodable>(_ type: T.Type, from messagePack: MessagePackValue) throws -> T {
        let decoder = _MessagePackDecoder(value: messagePack)
        return try T(from: decoder)
    }
}

// MARK: - _MessagePackDecoder

final class _MessagePackDecoder {
    
    fileprivate let value: MessagePackValue
    
    init(value: MessagePackValue) {
        self.value = value
    }
}

// MARK: Decoder
extension _MessagePackDecoder: Decoder {
    
    // TODO: Implement Me!
    var codingPath: [CodingKey] { return [] }
    
    // TODO: Implement Me!
    var userInfo: [CodingUserInfoKey : Any] { return [:] }
    
    func container<Key: CodingKey>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        
        guard case let .map(map) = value else {
            let msg = "Cannot decode map from \(value)"
            let context = DecodingError.Context(codingPath: [], debugDescription: msg)
            throw DecodingError.typeMismatch([MessagePackValue: MessagePackValue].self, context)
        }
        
        let container = MessagePackKeyedDecodingContainer<Key>(map: map)
        return KeyedDecodingContainer(container)
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        
        guard case let .array(array) = value else {
            let msg = "Cannot decode array from \(value)"
            let context = DecodingError.Context(codingPath: [], debugDescription: msg)
            throw DecodingError.typeMismatch([MessagePackValue].self, context)
        }
        
        return MessagePackUnkeyedDecodingContainer(array: array)
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return MessagePackSingleValueDecodingContainer(value: value)
    }
}
