//
//  MessagePackValueTranslator.swift
//  MessagePack
//
//  Created by cherrywoods on 09.02.18.
//  Licensed under Unlicense, https://unlicense.org
//

import Foundation
import MetaSerialization

/**
 Implements the Translator protocol from MetaSerialization
 to convert from arbitrary codable types to MessagePackValue.
 */
internal struct MessagePackValueTranslator: Translator {
    
    // MARK: - meta tree stage
    
    // use default implementations for container methods
    
    internal func wrappingMeta<T>(for value: T) -> Meta? {
        
        switch value {
           
        // support nil values
        case is GenericNil:
            return NilMeta.nil
            
        // these types need no conversion
        // use SimpleGenericMeta for all these
        case is String: fallthrough
        case is Bool: fallthrough
        case is Float: fallthrough
        case is Double: fallthrough
        case is Int64, is Int, is Int8, is Int16, is Int32 : fallthrough
        case is UInt64, is UInt, is UInt8, is UInt16, is UInt32 : fallthrough
        case is Data: fallthrough
        // also MessagePackValues can be encoded
        // they just get passed on
        case is MessagePackValue:
            return SimpleGenericMeta<T>()
            
        // return nil for all other values
        default:
            return nil
        }
        
    }
    
    internal func unwrap<T>(meta: Meta, toType type: T.Type) throws -> T? {
        
        if let message = (meta as? SimpleGenericMeta<MessagePackValue>)?.value {
            
            // nil values do not reach to this method
            
            switch type {
            // directly convertible types
            case is String.Type:
                // need to throw an error, if type is string, but message not convertible
                guard let value = message.stringValue else { throw TranslatorError.typeMismatch }
                return (value as! T)
            case is Bool.Type:
                guard let value = message.boolValue else { throw TranslatorError.typeMismatch }
                return (value as! T)
            case is Float.Type:
                guard let value = message.floatValue else { throw TranslatorError.typeMismatch }
                return (value as! T)
            case is Double.Type:
                guard let value = message.doubleValue else { throw TranslatorError.typeMismatch }
                return (value as! T)
            case is Int64.Type:
                guard let value = message.integerValue else { throw TranslatorError.typeMismatch }
                return (value as! T)
            case is UInt64.Type:
                guard let value = message.unsignedIntegerValue else { throw TranslatorError.typeMismatch }
                return (value as! T)
            case is Data.Type:
                guard let value = message.dataValue else { throw TranslatorError.typeMismatch }
                return (value as! T)
            case is MessagePackValue.Type:
                return (message as! T)
            // all further int types need conversion
            case is Int.Type:
                guard let int64 = message.integerValue else { throw TranslatorError.typeMismatch }
                guard let value = Int(exactly: int64) else { throw TranslatorError.typeMismatch }
                return (value as! T)
            case is Int8.Type:
                guard let int64 = message.integerValue else { throw TranslatorError.typeMismatch }
                guard let value = Int8(exactly: int64) else { throw TranslatorError.typeMismatch }
                return (value as! T)
            case is Int16.Type:
                guard let int64 = message.integerValue else { throw TranslatorError.typeMismatch }
                guard let value = Int16(exactly: int64) else { throw TranslatorError.typeMismatch }
                return (value as! T)
            case is Int32.Type:
                guard let int64 = message.integerValue else { throw TranslatorError.typeMismatch }
                guard let value = Int32(exactly: int64) else { throw TranslatorError.typeMismatch }
                return (value as! T)
            case is UInt.Type:
                guard let uint64 = message.unsignedIntegerValue else { throw TranslatorError.typeMismatch }
                guard let value = UInt(exactly: uint64) else { throw TranslatorError.typeMismatch }
                return (value as! T)
            case is UInt8.Type:
                guard let uint64 = message.unsignedIntegerValue else { throw TranslatorError.typeMismatch }
                guard let value = UInt8(exactly: uint64) else { throw TranslatorError.typeMismatch }
                return (value as! T)
            case is UInt16.Type:
                guard let uint64 = message.unsignedIntegerValue else { throw TranslatorError.typeMismatch }
                guard let value = UInt16(exactly: uint64) else { throw TranslatorError.typeMismatch }
                return (value as! T)
            case is UInt32.Type:
                guard let uint64 = message.unsignedIntegerValue else { throw TranslatorError.typeMismatch }
                guard let value = UInt32(exactly: uint64) else { throw TranslatorError.typeMismatch }
                return (value as! T)
                
            // return nil for all other types, they may still use e.g. a singleValueContainer
            default:
                return nil
            }
            
        } else {
            
            // not a primitive meta
            return nil
            
        }
        
    }
    
    // MARK: - conversion stage
    
    internal func encode<Raw>(_ meta: Meta) throws -> Raw {
        return encodeToMessagePackValue(meta) as! Raw
    }
    
    private func encodeToMessagePackValue(_ meta: Meta) -> MessagePackValue {
        
        // nil
        if meta is NilMeta {
            return MessagePackValue.nil
            
        // other types
        } else if let value = (meta as? SimpleGenericMeta<String>)?.value {
            return MessagePackValue.string(value)
        }  else if let value = (meta as? SimpleGenericMeta<Bool>)?.value {
            return MessagePackValue.bool(value)
        } else if let value = (meta as? SimpleGenericMeta<Float>)?.value {
            return MessagePackValue.float(value)
        } else if let value = (meta as? SimpleGenericMeta<Double>)?.value {
            return MessagePackValue.double(value)
        } else if let value = (meta as? SimpleGenericMeta<Int64>)?.value {
            return MessagePackValue.int(value)
        } else if let value = (meta as? SimpleGenericMeta<UInt64>)?.value {
            return MessagePackValue.uint(value)
        } else if let value = (meta as? SimpleGenericMeta<Data>)?.value {
            return MessagePackValue.binary(value)
        } else if let value = (meta as? SimpleGenericMeta<MessagePackValue>)?.value {
            // directly pass on value
            return value
            
        // other ints
        } else if let value = (meta as? SimpleGenericMeta<Int>)?.value {
            return MessagePackValue(value)
        } else if let value = (meta as? SimpleGenericMeta<Int8>)?.value {
            return MessagePackValue(value)
        } else if let value = (meta as? SimpleGenericMeta<Int16>)?.value {
            return MessagePackValue(value)
        } else if let value = (meta as? SimpleGenericMeta<Int32>)?.value {
            return MessagePackValue(value)
        } else if let value = (meta as? SimpleGenericMeta<UInt>)?.value {
            return MessagePackValue(value)
        } else if let value = (meta as? SimpleGenericMeta<UInt8>)?.value {
            return MessagePackValue(value)
        } else if let value = (meta as? SimpleGenericMeta<UInt16>)?.value {
            return MessagePackValue(value)
        } else if let value = (meta as? SimpleGenericMeta<UInt32>)?.value {
            return MessagePackValue(value)
        
        // convert keyed and unkeyed containers
        } else if let dictionary = (meta as? DictionaryKeyedContainerMeta)?.value {
            
            // convert keys to .string and encode values
            let converted = dictionary.map { (MessagePackValue.string($0), encodeToMessagePackValue($1)) }
            return MessagePackValue.map( Dictionary(uniqueKeysWithValues: converted) )
            
        } else if let array = (meta as? ArrayUnkeyedContainerMeta)?.value {
            
            let converted = array.map( encodeToMessagePackValue )
            return MessagePackValue.array(converted)
            
        } else {
            // we did not create other metas,
            // so the call of this shows a bug
            assertionFailure()
            return MessagePackValue.nil
        }
        
    }
    
    internal func decode<Raw>(_ raw: Raw) throws -> Meta {
        
        let message = raw as! MessagePackValue
        
        // decode arrays and dictionarys
        switch message {
            
        // if is .nil, need to return a NilMeta
        case .nil:
            return NilMeta.nil
            
        // convert arrays to ArrayUnkeyedContainerMetas
        case .array(let value):
            let unkeyed = ArrayUnkeyedContainerMeta()
            // decode and append each element of value
            try value.forEach { unkeyed.append(element: try decode($0)) }
            return unkeyed
            
        // convert maps to DictionaryKeyedContainerMetas
        case .map(let value):
            let keyed = DictionaryKeyedContainerMeta()
            // convert keys to string values and decode values
            try value.forEach { (key, value) in keyed[try codingKeyStringValue(of: key)] = try decode(value) }
            return keyed
            
        default:
            
            // if none of the above,
            // do not decode at all.
            // All the work here is done in unwrap
            return SimpleGenericMeta(value: message)
            
        }
        
    }
    
    // converts strings, binarys and ints to string values
    private func codingKeyStringValue(of message: MessagePackValue) throws -> String {
        
        // handle string and binary
        if let stringValue = message.stringValue {
            
            return stringValue
            
        } else if let intValue = message.integerValue {
            
            return "\(intValue)"
            
        } else if let uintValue = message.unsignedIntegerValue {
            
            return "\(uintValue)"
            
        } else {
            
            let context = DecodingError.Context(codingPath: [], debugDescription: "Unsupported key type of map. Keys need to be .string, .binary, .int or .uint")
            throw DecodingError.dataCorrupted(context)
            
        }
        
    }
    
}
