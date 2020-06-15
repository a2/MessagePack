//
//  _MessagePackEncoder.swift
//  MessagePack
//
//  Created by Andrew Eng on 27/2/18.
//

import Foundation

// MARK: - _MessagePackEncoder
final class _MessagePackEncoder {
    
    var messagePack: MessagePackValue {
        return storage?.messagePack ?? .`nil`
    }
    
    struct Options {
        let keyedEncodingOptions: MessagePackEncoder.KeyedEncodingOptions
        let userInfo: [CodingUserInfoKey: Any]
    }
    
    fileprivate let options: Options
    fileprivate var storage: MessagePackStorage?
    
    init(options: Options) {
        self.options = options
    }
    
    fileprivate func existingStorage<T: MessagePackStorage>(type: T.Type) -> T? {
        guard let storage = storage else { return nil }
        
        guard let requiredStorage = storage as? T else {
            fatalError()
        }
        
        return requiredStorage
    }
}

// MARK: Encoder
extension _MessagePackEncoder: Encoder {
    
    // TODO: Implement Me!
    var codingPath: [CodingKey] { return [] }
    
    var userInfo: [CodingUserInfoKey : Any] { return options.userInfo }
    
    func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
        let storage: MessagePackDictionaryStorage
        
        if let existingStorage = existingStorage(type: MessagePackDictionaryStorage.self) {
            storage = existingStorage
        } else {
            storage = MessagePackDictionaryStorage()
            self.storage = storage
        }
        
        let container = MessagePackKeyedEncodingContainer<Key>(storage: storage, options: options)
        return KeyedEncodingContainer(container)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        let storage: MessagePackArrayStorage
        
        if let existingStorage = existingStorage(type: MessagePackArrayStorage.self) {
            storage = existingStorage
        } else {
            storage = MessagePackArrayStorage()
            self.storage = storage
        }
        
        return MessagePackUnkeyedEncodingContainer(storage: storage, options: options)
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        let storage: MessagePackValueStorage
        
        if let existingStorage = existingStorage(type: MessagePackValueStorage.self) {
            storage = existingStorage
        } else {
            storage = MessagePackValueStorage()
            self.storage = storage
        }
        
        return MessagePackSingleValueEncodingContainer(storage: storage, options: options)
    }
}
