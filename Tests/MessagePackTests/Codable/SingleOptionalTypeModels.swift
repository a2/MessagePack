//
//  SingleOptionalTypeModels.swift
//  MessagePackTests
//
//  Created by Andrew Eng on 23/2/18.
//

import Foundation

import Foundation
import XCTest
@testable import MessagePack

protocol SingleOptionalTypeModel: OptionalModel {
    associatedtype T: Codable
    var value: T? { get }
    func _messagePack() -> MessagePackValue?
}

extension SingleOptionalTypeModel {
    var encoded: MessagePackValue {
        let value = _messagePack() ?? .`nil`
        return .map([.string("value"): value])
    }
    var encodedIgnoringNil: MessagePackValue {
        if let value = _messagePack() {
            return .map([.string("value"): value])
        } else {
            return .map([:])
        }
    }
}
extension SingleOptionalTypeModel where Self.T: Equatable {
    static func ==(lhs: Self, rhs: Self) -> Bool { return lhs.value == rhs.value }
}

// MARK: - Models

struct OptionalBoolModel: SingleOptionalTypeModel {
    let value: Bool?
    func _messagePack() -> MessagePackValue? { return value.map({ .bool($0) }) }
}
struct OptionalIntModel: SingleOptionalTypeModel {
    let value: Int?
    func _messagePack() -> MessagePackValue? { return value.map({ .int(Int64($0)) }) }
}
struct OptionalInt8Model: SingleOptionalTypeModel {
    let value: Int8?
    func _messagePack() -> MessagePackValue? { return value.map({ .int(Int64($0)) }) }
}
struct OptionalInt16Model: SingleOptionalTypeModel {
    let value: Int16?
    func _messagePack() -> MessagePackValue? { return value.map({ .int(Int64($0)) }) }
}
struct OptionalInt32Model: SingleOptionalTypeModel {
    let value: Int32?
    func _messagePack() -> MessagePackValue? { return value.map({ .int(Int64($0)) }) }
}
struct OptionalInt64Model: SingleOptionalTypeModel {
    let value: Int64?
    func _messagePack() -> MessagePackValue? { return value.map({ .int($0) }) }
}
struct OptionalUIntModel: SingleOptionalTypeModel {
    let value: UInt?
    func _messagePack() -> MessagePackValue? { return value.map({ .uint(UInt64($0)) }) }
}
struct OptionalUInt8Model: SingleOptionalTypeModel {
    let value: UInt8?
    func _messagePack() -> MessagePackValue? { return value.map({ .uint(UInt64($0)) }) }
}
struct OptionalUInt16Model: SingleOptionalTypeModel {
    let value: UInt16?
    func _messagePack() -> MessagePackValue? { return value.map({ .uint(UInt64($0)) }) }
}
struct OptionalUInt32Model: SingleOptionalTypeModel {
    let value: UInt32?
    func _messagePack() -> MessagePackValue? { return value.map({ .uint(UInt64($0)) }) }
}
struct OptionalUInt64Model: SingleOptionalTypeModel {
    let value: UInt64?
    func _messagePack() -> MessagePackValue? { return value.map({ .uint($0) }) }
}
struct OptionalFloatModel: SingleOptionalTypeModel {
    let value: Float?
    func _messagePack() -> MessagePackValue? { return value.map({ .float($0) }) }
}
struct OptionalDoubleModel: SingleOptionalTypeModel {
    let value: Double?
    func _messagePack() -> MessagePackValue? { return value.map({ .double($0) }) }
}
struct OptionalStringModel: SingleOptionalTypeModel {
    let value: String?
    func _messagePack() -> MessagePackValue? { return value.map({ .string($0) }) }
}
struct OptionalDataModel: SingleOptionalTypeModel {
    let value: Data?
    func _messagePack() -> MessagePackValue? { return value.map({ .binary($0) }) }
}
struct OptionalArrayModel: SingleOptionalTypeModel {
    let value: [String]?
    func _messagePack() -> MessagePackValue? {
        guard let value = value else { return nil }
        let array: [MessagePackValue] = value.map({ .string($0) })
        return .array(array)
    }
    static func ==(lhs: OptionalArrayModel, rhs: OptionalArrayModel) -> Bool {
        if let lhsValue = lhs.value, let rhsValue = rhs.value {
            return lhsValue == rhsValue
        } else if lhs.value == nil && rhs.value == nil {
            return true
        } else {
            return false
        }
    }
}
struct OptionalMapModel: SingleOptionalTypeModel {
    let value: [String: UInt64]?
    func _messagePack() -> MessagePackValue? {
        guard let value = value else { return nil }
        var map = [MessagePackValue: MessagePackValue]()
        value.forEach({ map[.string($0)] = .uint($1) })
        return .map(map)
    }
    static func ==(lhs: OptionalMapModel, rhs: OptionalMapModel) -> Bool {
        if let lhsValue = lhs.value, let rhsValue = rhs.value {
            return lhsValue == rhsValue
        } else if lhs.value == nil && rhs.value == nil {
            return true
        } else {
            return false
        }
    }
}
