//
//  MessagePackValueSerialization.swift
//  MessagePack
//
//  Created by cherrywoods on 09.02.18.
//  Licensed under Unlicense, https://unlicense.org
//

import Foundation
import MetaSerialization

public typealias CodableConverter = MessagePackValueSerialization

/**
 MessagePackValueSerialization (or just CodableConverted) encodes or decodes
 Codable types from MessagePackValue instances.
 
 With it's help you may easily encode and decode more complex types implementing
 Codable, including many Foundation types, as Array, Dictionary or Date.
 
 You may mix both ways of serialization. You could for example have a MessagePackValue property,
 or encode a MessagePackValue to a container in your implementation of Encodable's encode(to:) method.
 Both will be kept in the serialized MessagePackValue.
 */
public class MessagePackValueSerialization: Serialization {
    
    public typealias Raw = MessagePackValue
    
    public func provideNewEncoder() -> MetaEncoder {
        return MetaEncoder(translator: MessagePackValueTranslator())
    }
    
    public func provideNewDecoder(raw: MessagePackValue) throws -> MetaDecoder {
        return try MetaDecoder(translator: MessagePackValueTranslator(), raw: raw)
    }
    
}
