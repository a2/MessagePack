//
//  MessagePackUnkeyedDecodingContainer.swift
//  MessagePack
//
//  Created by Andrew Eng on 20/2/18.
//

import Foundation

final class MessagePackUnkeyedDecodingContainer {
    
    let array: [MessagePackValue]
    fileprivate(set) var currentIndex: Int
    
    init(array: [MessagePackValue]) {
        self.array = array
        self.currentIndex = 0
    }
}

// MARK: - Helper
extension MessagePackUnkeyedDecodingContainer {
    
    fileprivate func _decode<T: MessagePackRepresentable>(_ type: T.Type) throws -> T {
        try ensureNotAtEnd(type: type)
        
        guard let value = T(messagePack: array[currentIndex]) else {
            let msg = "Cannot decode \(type) from \(array[currentIndex])"
            let context = DecodingError.Context(codingPath: [], debugDescription: msg)
            throw DecodingError.typeMismatch(type, context)
        }
        
        currentIndex += 1
        return value
    }
    
    fileprivate func _decodeDecodable<T: Decodable>(_ type: T.Type) throws -> T {
        try ensureNotAtEnd(type: type)
        
        let decoder = _MessagePackDecoder(value: array[currentIndex])
        let decoded = try T(from: decoder)
        
        currentIndex += 1
        return decoded
    }
    
    fileprivate func ensureNotAtEnd(type: Any.Type) throws {
        
        guard !isAtEnd else {
            let msg = "Unkeyed container is at end"
            let context = DecodingError.Context(codingPath: [], debugDescription: msg)
            throw DecodingError.valueNotFound(type, context)
        }
    }
}

// MARK: - UnkeyedDecodingContainer
extension MessagePackUnkeyedDecodingContainer: UnkeyedDecodingContainer {
    
    // TODO: Implement Me!
    var codingPath: [CodingKey] { return [] }
    
    var count: Int? { return array.count }
    var isAtEnd: Bool { return (currentIndex == array.count) }
    
    func decodeNil() throws -> Bool {
        try ensureNotAtEnd(type: Bool.self)
        
        if case .`nil` = array[currentIndex] {
            currentIndex += 1
            return true
        } else {
            return false
        }
    }
    
    func decode(_ type: Bool.Type) throws -> Bool     { return try _decode(type) }
    func decode(_ type: Int.Type) throws -> Int       { return try _decode(type) }
    func decode(_ type: Int8.Type) throws -> Int8     { return try _decode(type) }
    func decode(_ type: Int16.Type) throws -> Int16   { return try _decode(type) }
    func decode(_ type: Int32.Type) throws -> Int32   { return try _decode(type) }
    func decode(_ type: Int64.Type) throws -> Int64   { return try _decode(type) }
    func decode(_ type: UInt.Type) throws -> UInt     { return try _decode(type) }
    func decode(_ type: UInt8.Type) throws -> UInt8   { return try _decode(type) }
    func decode(_ type: UInt16.Type) throws -> UInt16 { return try _decode(type) }
    func decode(_ type: UInt32.Type) throws -> UInt32 { return try _decode(type) }
    func decode(_ type: UInt64.Type) throws -> UInt64 { return try _decode(type) }
    func decode(_ type: Float.Type) throws -> Float   { return try _decode(type) }
    func decode(_ type: Double.Type) throws -> Double { return try _decode(type) }
    func decode(_ type: String.Type) throws -> String { return try _decode(type) }
    
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        
        if T.self == Data.self || T.self == NSData.self {
            return try _decode(Data.self) as! T
        } else {
            return try _decodeDecodable(type)
        }
    }
    
    func nestedContainer<NestedKey: CodingKey>(keyedBy type: NestedKey.Type)
        throws -> KeyedDecodingContainer<NestedKey>
    {
        try ensureNotAtEnd(type: [MessagePackValue: MessagePackValue].self)
        
        guard case let .map(map) = array[currentIndex] else {
            let msg = "Cannot decode map from \(array[currentIndex])"
            let context = DecodingError.Context(codingPath: [], debugDescription: msg)
            throw DecodingError.typeMismatch([MessagePackValue: MessagePackValue].self, context)
        }
        
        let container = MessagePackKeyedDecodingContainer<NestedKey>(map: map)
        return KeyedDecodingContainer(container)
    }
    
    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        try ensureNotAtEnd(type: [MessagePackValue].self)
        
        guard case let .array(array) = array[currentIndex] else {
            let msg = "Cannot decode array from \(self.array[currentIndex])"
            let context = DecodingError.Context(codingPath: [], debugDescription: msg)
            throw DecodingError.typeMismatch([MessagePackValue].self, context)
        }
        
        currentIndex += 1
        return MessagePackUnkeyedDecodingContainer(array: array)
    }
    
    // TODO: Implement Me!
    func superDecoder() throws -> Decoder { abort() }
}
