//
//  MessagePackSingleValueDecodingContainer.swift
//  MessagePack
//
//  Created by Andrew Eng on 20/2/18.
//

import Foundation

final class MessagePackSingleValueDecodingContainer {
    
    let value: MessagePackValue
    
    init(value: MessagePackValue) {
        self.value = value
    }
}

// MARK: - Helper
extension MessagePackSingleValueDecodingContainer {
    
    fileprivate func _decode<T: MessagePackRepresentable>(_ type: T.Type) throws -> T {
        
        guard let value = T(messagePack: self.value) else {
            let msg = "Cannot decode \(type) from \(self.value)"
            let context = DecodingError.Context(codingPath: [], debugDescription: msg)
            throw DecodingError.typeMismatch(type, context)
        }
        
        return value
    }
    
    fileprivate func _decodeDecodable<T: Decodable>(_ type: T.Type) throws -> T {
        
        let decoder = _MessagePackDecoder(value: value)
        return try T(from: decoder)
    }
}

// MARK: - SingleValueDecodingContainer
extension MessagePackSingleValueDecodingContainer: SingleValueDecodingContainer {

    // TODO: Implement Me!
    var codingPath: [CodingKey] { return [] }
    
    func decodeNil() -> Bool { return value == .`nil` }
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

    func decode<T: Decodable>(_ type: T.Type) throws -> T {
        
        if T.self == Data.self || T.self == NSData.self {
            return try _decode(Data.self) as! T
        } else {
            return try _decodeDecodable(type)
        }
    }
}
