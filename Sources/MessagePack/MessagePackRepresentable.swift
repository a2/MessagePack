//
//  MessagePackRepresentable.swift
//  MessagePack
//
//  Created by Andrew Eng on 20/2/18.
//

import Foundation

protocol MessagePackRepresentable {
    init?(messagePack: MessagePackValue)
    var messagePack: MessagePackValue { get }
}

extension Bool: MessagePackRepresentable {
    public init?(messagePack: MessagePackValue) {
        guard let value = messagePack.boolValue else { return nil }
        self = value
    }
    var messagePack: MessagePackValue { return MessagePackValue(self) }
}
extension Int: MessagePackRepresentable {
    public init?(messagePack: MessagePackValue) {
        guard let value = messagePack.intValue else { return nil }
        self = value
    }
    var messagePack: MessagePackValue { return MessagePackValue(self) }
}
extension Int8: MessagePackRepresentable {
    public init?(messagePack: MessagePackValue) {
        guard let value = messagePack.int8Value else { return nil }
        self = value
    }
    var messagePack: MessagePackValue { return MessagePackValue(self) }
}
extension Int16: MessagePackRepresentable {
    public init?(messagePack: MessagePackValue) {
        guard let value = messagePack.int16Value else { return nil }
        self = value
    }
    var messagePack: MessagePackValue { return MessagePackValue(self) }
}
extension Int32: MessagePackRepresentable {
    public init?(messagePack: MessagePackValue) {
        guard let value = messagePack.int32Value else { return nil }
        self = value
    }
    var messagePack: MessagePackValue { return MessagePackValue(self) }
}
extension Int64: MessagePackRepresentable {
    public init?(messagePack: MessagePackValue) {
        guard let value = messagePack.int64Value else { return nil }
        self = value
    }
    var messagePack: MessagePackValue { return MessagePackValue(self) }
}
extension UInt: MessagePackRepresentable {
    public init?(messagePack: MessagePackValue) {
        guard let value = messagePack.uintValue else { return nil }
        self = value
    }
    var messagePack: MessagePackValue { return MessagePackValue(self) }
}
extension UInt8: MessagePackRepresentable {
    public init?(messagePack: MessagePackValue) {
        guard let value = messagePack.uint8Value else { return nil }
        self = value
    }
    var messagePack: MessagePackValue { return MessagePackValue(self) }
}
extension UInt16: MessagePackRepresentable {
    public init?(messagePack: MessagePackValue) {
        guard let value = messagePack.uint16Value else { return nil }
        self = value
    }
    var messagePack: MessagePackValue { return MessagePackValue(self) }
}
extension UInt32: MessagePackRepresentable {
    public init?(messagePack: MessagePackValue) {
        guard let value = messagePack.uint32Value else { return nil }
        self = value
    }
    var messagePack: MessagePackValue { return MessagePackValue(self) }
}
extension UInt64: MessagePackRepresentable {
    public init?(messagePack: MessagePackValue) {
        guard let value = messagePack.uint64Value else { return nil }
        self = value
    }
    var messagePack: MessagePackValue { return MessagePackValue(self) }
}
extension Float: MessagePackRepresentable {
    public init?(messagePack: MessagePackValue) {
        guard let value = messagePack.floatValue else { return nil }
        self = value
    }
    var messagePack: MessagePackValue { return MessagePackValue(self) }
}
extension Double: MessagePackRepresentable {
    public init?(messagePack: MessagePackValue) {
        guard let value = messagePack.doubleValue else { return nil }
        self = value
    }
    var messagePack: MessagePackValue { return MessagePackValue(self) }
}
extension String: MessagePackRepresentable {
    public init?(messagePack: MessagePackValue) {
        guard let value = messagePack.stringValue else { return nil }
        self = value
    }
    var messagePack: MessagePackValue { return MessagePackValue(self) }
}
extension Data: MessagePackRepresentable {
    public init?(messagePack: MessagePackValue) {
        guard let value = messagePack.dataValue else { return nil }
        self = value
    }
    var messagePack: MessagePackValue { return MessagePackValue(self) }
}
