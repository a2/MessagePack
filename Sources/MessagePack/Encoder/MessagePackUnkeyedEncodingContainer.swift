//
//  MessagePackUnkeyedEncodingContainer.swift
//  MessagePack
//
//  Created by Andrew Eng on 20/2/18.
//

import Foundation

final class MessagePackUnkeyedEncodingContainer {

    fileprivate let storage: MessagePackArrayStorage
    fileprivate let options: _MessagePackEncoder.Options
    
    init(storage: MessagePackArrayStorage, options: _MessagePackEncoder.Options) {
        self.storage = storage
        self.options = options
    }
}

// MARK: - Helper
extension MessagePackUnkeyedEncodingContainer {
    
    fileprivate func _encode<T: MessagePackRepresentable>(_ value: T) throws {
        storage.append(value.messagePack)
    }
    
    fileprivate func _encodeEncodable<T: Encodable>(_ value: T) throws {
        let encoder = _MessagePackEncoder(options: options)
        try value.encode(to: encoder)
        storage.append(encoder.messagePack)
    }
}

// MARK: - UnkeyedEncodingContainer
extension MessagePackUnkeyedEncodingContainer: UnkeyedEncodingContainer {
    
    // TODO: Implement Me!
    var codingPath: [CodingKey] { return [] }
    
    var count: Int { return storage.count }
    
    func encodeNil() throws { storage.append(.`nil`) }
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
    
    func encode<T: Encodable>(_ value: T) throws {
        
        if T.self == Data.self || T.self == NSData.self {
            try _encode(value as! Data)
        } else {
            try _encodeEncodable(value)
        }
    }
    
    func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> {
        let storage = MessagePackDictionaryStorage()
        self.storage.append(storage)
        let container = MessagePackKeyedEncodingContainer<NestedKey>(storage: storage, options: options)
        return KeyedEncodingContainer(container)
    }
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        let storage = MessagePackArrayStorage()
        self.storage.append(storage)
        return MessagePackUnkeyedEncodingContainer(storage: storage, options: options)
    }
    
    // TODO: Implement Me!
    func superEncoder() -> Encoder { abort() }
}
