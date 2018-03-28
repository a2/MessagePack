//
//  MessagePackEncoder.swift
//  MessagePack
//
//  Created by Andrew Eng on 20/2/18.
//

import Foundation

open class MessagePackEncoder {
    
    open var userInfo: [CodingUserInfoKey: Any] = [:]
    
    public struct KeyedEncodingOptions: OptionSet {
        public let rawValue: Int
        public init(rawValue: Int) { self.rawValue = rawValue }
        
        public static let ignoreKeysWithNilValue = KeyedEncodingOptions(rawValue: 1 << 0)
    }
    open static var defaultKeyedEncodingOptions: KeyedEncodingOptions = []
    open var keyedEncodingOptions = MessagePackEncoder.defaultKeyedEncodingOptions
    
    public init() {}
    
    open func encode<T: Encodable>(_ value: T) throws -> Data {
        let messagePack = try encodeToMessagePack(value)
        return try encodeMessagePack(messagePack)
    }
    
    open func encodeToMessagePack<T: Encodable>(_ value: T) throws -> MessagePackValue {
        let options = _MessagePackEncoder.Options(keyedEncodingOptions: keyedEncodingOptions,
                                                  userInfo: userInfo)
        let encoder = _MessagePackEncoder(options: options)
        try value.encode(to: encoder)
        return encoder.messagePack
    }
    
    open func encodeMessagePack(_ messagePack: MessagePackValue) throws -> Data {
        return pack(messagePack)
    }
}
