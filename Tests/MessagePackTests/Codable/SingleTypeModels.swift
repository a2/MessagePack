//
//  SingleTypeModels.swift
//  MessagePackTests
//
//  Created by Andrew Eng on 21/2/18.
//

import Foundation
import XCTest
@testable import MessagePack

protocol SingleTypeModel: Model {
    associatedtype T: Codable
    var value: T { get }
    func _messagePack() -> MessagePackValue
}

extension SingleTypeModel {
    var encoded: MessagePackValue { return .map([.string("value"): _messagePack()]) }
}
extension SingleTypeModel where Self.T: Equatable {
    static func ==(lhs: Self, rhs: Self) -> Bool { return lhs.value == rhs.value }
}

// MARK: - Models

struct NilModel: SingleTypeModel {
    let value: Bool? = nil
    func _messagePack() -> MessagePackValue { return .`nil` }
    static func ==(lhs: NilModel, rhs: NilModel) -> Bool { return lhs.value == rhs.value }
}
struct BoolModel: SingleTypeModel {
    let value: Bool
    func _messagePack() -> MessagePackValue { return .bool(value) }
}
struct IntModel: SingleTypeModel {
    let value: Int
    func _messagePack() -> MessagePackValue { return .int(Int64(value)) }
}
struct Int8Model: SingleTypeModel {
    let value: Int8
    func _messagePack() -> MessagePackValue { return .int(Int64(value)) }
}
struct Int16Model: SingleTypeModel {
    let value: Int16
    func _messagePack() -> MessagePackValue { return .int(Int64(value)) }
}
struct Int32Model: SingleTypeModel {
    let value: Int32
    func _messagePack() -> MessagePackValue { return .int(Int64(value)) }
}
struct Int64Model: SingleTypeModel {
    let value: Int64
    func _messagePack() -> MessagePackValue { return .int(value) }
}
struct UIntModel: SingleTypeModel {
    let value: UInt
    func _messagePack() -> MessagePackValue { return .uint(UInt64(value)) }
}
struct UInt8Model: SingleTypeModel {
    let value: UInt8
    func _messagePack() -> MessagePackValue { return .uint(UInt64(value)) }
}
struct UInt16Model: SingleTypeModel {
    let value: UInt16
    func _messagePack() -> MessagePackValue { return .uint(UInt64(value)) }
}
struct UInt32Model: SingleTypeModel {
    let value: UInt32
    func _messagePack() -> MessagePackValue { return .uint(UInt64(value)) }
}
struct UInt64Model: SingleTypeModel {
    let value: UInt64
    func _messagePack() -> MessagePackValue { return .uint(value) }
}
struct FloatModel: SingleTypeModel {
    let value: Float
    func _messagePack() -> MessagePackValue { return .float(value) }
}
struct DoubleModel: SingleTypeModel {
    let value: Double
    func _messagePack() -> MessagePackValue { return .double(value) }
}
struct StringModel: SingleTypeModel {
    let value: String
    func _messagePack() -> MessagePackValue { return .string(value) }
}
struct DataModel: SingleTypeModel {
    let value: Data
    func _messagePack() -> MessagePackValue { return .binary(value) }
}
struct ArrayModel: SingleTypeModel {
    let value: [String]
    func _messagePack() -> MessagePackValue {
        let array: [MessagePackValue] = value.map({ .string($0) })
        return .array(array)
    }
    static func ==(lhs: ArrayModel, rhs: ArrayModel) -> Bool { return lhs.value == rhs.value }
}
struct MapModel: SingleTypeModel {
    let value: [String: UInt64]
    func _messagePack() -> MessagePackValue {
        var map = [MessagePackValue: MessagePackValue]()
        value.forEach({ map[.string($0)] = .uint($1) })
        return .map(map)
    }
    static func ==(lhs: MapModel, rhs: MapModel) -> Bool { return lhs.value == rhs.value }
}
