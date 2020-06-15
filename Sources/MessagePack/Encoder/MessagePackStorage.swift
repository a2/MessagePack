//
//  MessagePackStorage.swift
//  MessagePack
//
//  Created by Andrew Eng on 20/2/18.
//

import Foundation

protocol MessagePackStorage {
    var messagePack: MessagePackValue { get }
}

final class MessagePackValueStorage: MessagePackStorage {
    var value: MessagePackValue
    
    init(_ value: MessagePackValue) {
        self.value = value
    }
    
    convenience init() {
        self.init(.`nil`)
    }
    
    var messagePack: MessagePackValue {
        return value
    }
}

final class MessagePackDictionaryStorage: MessagePackStorage {
    private var map: [String: MessagePackStorage] = [:]
    
    var messagePack: MessagePackValue {
        var map = [MessagePackValue: MessagePackValue]()
        self.map.forEach { map[.string($0)] = $1.messagePack }
        return .map(map)
    }
    
    subscript(key: String) -> MessagePackStorage? {
        get { return map[key] }
        set { map[key] = newValue }
    }
    
    subscript(key: String) -> MessagePackValue? {
        get { return map[key]?.messagePack }
        set {
            if let newValue = newValue {
                map[key] = MessagePackValueStorage(newValue)
            } else {
                map[key] = nil
            }
        }
    }
}

final class MessagePackArrayStorage: MessagePackStorage {
    private var array: [MessagePackStorage] = []
    
    var count: Int { return array.count }
    
    var messagePack: MessagePackValue {
        let array = self.array.map { $0.messagePack }
        return .array(array)
    }
    
    func append(_ storage: MessagePackStorage) {
        array.append(storage)
    }
    
    func append(_ messagePack: MessagePackValue) {
        array.append(MessagePackValueStorage(messagePack))
    }
}
