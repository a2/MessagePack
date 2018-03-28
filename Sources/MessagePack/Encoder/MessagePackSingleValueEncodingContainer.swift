//
//  MessagePackSingleValueEncodingContainer.swift
//  MessagePack
//
//  Created by Andrew Eng on 20/2/18.
//

import Foundation

final class MessagePackSingleValueEncodingContainer {
    
    fileprivate let storage: MessagePackValueStorage
    fileprivate let options: _MessagePackEncoder.Options
    
    init(storage: MessagePackValueStorage, options: _MessagePackEncoder.Options) {
        self.storage = storage
        self.options = options
    }
}

// MARK: - Helper
extension MessagePackSingleValueEncodingContainer {
    
    fileprivate func _encode<T: MessagePackRepresentable>(_ value: T) throws {
        storage.value = value.messagePack
    }
    
    fileprivate func _encodeEncodable<T: Encodable>(_ value: T) throws {
        let encoder = _MessagePackEncoder(options: options)
        try value.encode(to: encoder)
        storage.value = encoder.messagePack
    }
}

// MARK: - SingleValueEncodingContainer
extension MessagePackSingleValueEncodingContainer: SingleValueEncodingContainer {
    
    // TODO: Implement Me!
    var codingPath: [CodingKey] { return [] }
    
    func encodeNil() throws { storage.value = .`nil` }
    func encode(_ value: Bool) throws   { try _encode(value) }
    func encode(_ value: Int) throws    { try _encode(value) }
    func encode(_ value: Int8) throws   { try _encode(value) }
    func encode(_ value: Int16) throws  { try _encode(value) }
    func encode(_ value: Int32) throws  { try _encode(value) }
    func encode(_ value: Int64) throws  { try _encode(value) }
    func encode(_ value: UInt) throws   { try _encode(value) }
    func encode(_ value: UInt8) throws  { try _encode(value) }
    func encode(_ value: UInt16) throws { try _encode(value) }
    func encode(_ value: UInt32) throws { try _encode(value) }
    func encode(_ value: UInt64) throws { try _encode(value) }
    func encode(_ value: Float) throws  { try _encode(value) }
    func encode(_ value: Double) throws { try _encode(value) }
    func encode(_ value: String) throws { try _encode(value) }

    func encode<T : Encodable>(_ value: T) throws {
        
        if T.self == Data.self || T.self == NSData.self {
            try _encode(value as! Data)
        } else {
            try _encodeEncodable(value)
        }
    }
}
