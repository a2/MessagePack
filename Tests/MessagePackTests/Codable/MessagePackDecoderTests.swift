//
//  MessagePackDecoderTests.swift
//  MessagePackTests
//
//  Created by Andrew Eng on 21/2/18.

import Foundation
import XCTest
@testable import MessagePack

class MessagePackDecoderTests: XCTestCase {
    
    private var decoder: MessagePackDecoder!
    
    override func setUp() {
        super.setUp()
        decoder = MessagePackDecoder()
    }
    
    override func tearDown() {
        decoder = nil
        super.tearDown()
    }
}

// MARK: - Single Type Models
extension MessagePackDecoderTests {
    
    func testShouldDecodeNilModel() {
        let model = NilModel()
        _testDecode(model: model)
    }
    func testShouldDecodeBoolModel() {
        let model = BoolModel(value: true)
        _testDecode(model: model)
    }
    func testShouldDecodeIntModel() {
        let model = IntModel(value: -42)
        _testDecode(model: model)
    }
    func testShouldDecodeInt8Model() {
        let model = Int8Model(value: -42)
        _testDecode(model: model)
    }
    func testShouldDecodeInt16Model() {
        let model = Int16Model(value: -42)
        _testDecode(model: model)
    }
    func testShouldDecodeInt32Model() {
        let model = Int32Model(value: -42)
        _testDecode(model: model)
    }
    func testShouldDecodeInt64Model() {
        let model = Int64Model(value: -42)
        _testDecode(model: model)
    }
    func testShouldDecodeUIntModel() {
        let model = UIntModel(value: 42)
        _testDecode(model: model)
    }
    func testShouldDecodeUInt8Model() {
        let model = UInt8Model(value: 42)
        _testDecode(model: model)
    }
    func testShouldDecodeUInt16Model() {
        let model = UInt16Model(value: 42)
        _testDecode(model: model)
    }
    func testShouldDecodeUInt32Model() {
        let model = UInt32Model(value: 42)
        _testDecode(model: model)
    }
    func testShouldDecodeUInt64Model() {
        let model = UInt64Model(value: 42)
        _testDecode(model: model)
    }
    func testShouldDecodeFloatModel() {
        let model = FloatModel(value: 3.14)
        _testDecode(model: model)
    }
    func testShouldDecodeDoubleModel() {
        let model = DoubleModel(value: 3.14)
        _testDecode(model: model)
    }
    func testShouldDecodeStringModel() {
        let model = StringModel(value: "a")
        _testDecode(model: model)
    }
    func testShouldDecodeDataModel() {
        let model = DataModel(value: Data(bytes: [0x42, 0x43, 0x44]))
        _testDecode(model: model)
    }
    func testShouldDecodeArrayModel() {
        let model = ArrayModel(value: ["a", "b", "c"])
        _testDecode(model: model)
    }
    func testShouldDecodeMapModel() {
        let model = MapModel(value: ["a": 42, "b": 43])
        _testDecode(model: model)
    }
}

// MARK: - SingleOptionalTypeModel
extension MessagePackDecoderTests {
    
    func testShouldDecodeOptionalBoolModel() {
        let model = OptionalBoolModel(value: true)
        _testDecode(model: model)
    }
    func testShouldDecodeOptionalIntModel() {
        let model = OptionalIntModel(value: -42)
        _testDecode(model: model)
    }
    func testShouldDecodeOptionalInt8Model() {
        let model = OptionalInt8Model(value: -42)
        _testDecode(model: model)
    }
    func testShouldDecodeOptionalInt16Model() {
        let model = OptionalInt16Model(value: -42)
        _testDecode(model: model)
    }
    func testShouldDecodeOptionalInt32Model() {
        let model = OptionalInt32Model(value: -42)
        _testDecode(model: model)
    }
    func testShouldDecodeOptionalInt64Model() {
        let model = OptionalInt64Model(value: -42)
        _testDecode(model: model)
    }
    func testShouldDecodeOptionalUIntModel() {
        let model = OptionalUIntModel(value: 42)
        _testDecode(model: model)
    }
    func testShouldDecodeOptionalUInt8Model() {
        let model = OptionalUInt8Model(value: 42)
        _testDecode(model: model)
    }
    func testShouldDecodeOptionalUInt16Model() {
        let model = OptionalUInt16Model(value: 42)
        _testDecode(model: model)
    }
    func testShouldDecodeOptionalUInt32Model() {
        let model = OptionalUInt32Model(value: 42)
        _testDecode(model: model)
    }
    func testShouldDecodeOptionalUInt64Model() {
        let model = OptionalUInt64Model(value: 42)
        _testDecode(model: model)
    }
    func testShouldDecodeOptionalFloatModel() {
        let model = OptionalFloatModel(value: 3.14)
        _testDecode(model: model)
    }
    func testShouldDecodeOptionalDoubleModel() {
        let model = OptionalDoubleModel(value: 3.14)
        _testDecode(model: model)
    }
    func testShouldDecodeOptionalStringModel() {
        let model = OptionalStringModel(value: "a")
        _testDecode(model: model)
    }
    func testShouldDecodeOptionalDataModel() {
        let model = OptionalDataModel(value: Data(bytes: [0x42, 0x43, 0x44]))
        _testDecode(model: model)
    }
    func testShouldDecodeOptionalArrayModel() {
        let model = OptionalArrayModel(value: ["a", "b", "c"])
        _testDecode(model: model)
    }
    func testShouldDecodeOptionalMapModel() {
        let model = OptionalMapModel(value: ["a": 42, "b": 43])
        _testDecode(model: model)
    }
}

// MARK: Empty SingleOptionalTypeModel
extension MessagePackDecoderTests {
    
    func testShouldDecodeEmptyOptionalBoolModel() {
        let model = OptionalBoolModel(value: nil)
        _testDecode(model: model)
    }
    func testShouldDecodeEmptyOptionalIntModel() {
        let model = OptionalIntModel(value: nil)
        _testDecode(model: model)
    }
    func testShouldDecodeEmptyOptionalInt8Model() {
        let model = OptionalInt8Model(value: nil)
        _testDecode(model: model)
    }
    func testShouldDecodeEmptyOptionalInt16Model() {
        let model = OptionalInt16Model(value: nil)
        _testDecode(model: model)
    }
    func testShouldDecodeEmptyOptionalInt32Model() {
        let model = OptionalInt32Model(value: nil)
        _testDecode(model: model)
    }
    func testShouldDecodeEmptyOptionalInt64Model() {
        let model = OptionalInt64Model(value: nil)
        _testDecode(model: model)
    }
    func testShouldDecodeEmptyOptionalUIntModel() {
        let model = OptionalUIntModel(value: nil)
        _testDecode(model: model)
    }
    func testShouldDecodeEmptyOptionalUInt8Model() {
        let model = OptionalUInt8Model(value: nil)
        _testDecode(model: model)
    }
    func testShouldDecodeEmptyOptionalUInt16Model() {
        let model = OptionalUInt16Model(value: nil)
        _testDecode(model: model)
    }
    func testShouldDecodeEmptyOptionalUInt32Model() {
        let model = OptionalUInt32Model(value: nil)
        _testDecode(model: model)
    }
    func testShouldDecodeEmptyOptionalUInt64Model() {
        let model = OptionalUInt64Model(value: nil)
        _testDecode(model: model)
    }
    func testShouldDecodeEmptyOptionalFloatModel() {
        let model = OptionalFloatModel(value: nil)
        _testDecode(model: model)
    }
    func testShouldDecodeEmptyOptionalDoubleModel() {
        let model = OptionalDoubleModel(value: nil)
        _testDecode(model: model)
    }
    func testShouldDecodeEmptyOptionalStringModel() {
        let model = OptionalStringModel(value: nil)
        _testDecode(model: model)
    }
    func testShouldDecodeEmptyOptionalDataModel() {
        let model = OptionalDataModel(value: nil)
        _testDecode(model: model)
    }
    func testShouldDecodeEmptyOptionalArrayModel() {
        let model = OptionalArrayModel(value: nil)
        _testDecode(model: model)
    }
    func testShouldDecodeEmptyOptionalMapModel() {
        let model = OptionalMapModel(value: nil)
        _testDecode(model: model)
    }
}

// MARK: SingleOptionalTypeModel with empty map
extension MessagePackDecoderTests {
    
    func testShouldDecodeOptionalBoolModelWithEmptyMap() {
        let model = OptionalBoolModel(value: nil)
        _testDecode(model: model, messagePack: .map([:]))
    }
    func testShouldDecodeOptionalIntModelWithEmptyMap() {
        let model = OptionalIntModel(value: nil)
        _testDecode(model: model, messagePack: .map([:]))
    }
    func testShouldDecodeOptionalInt8ModelWithEmptyMap() {
        let model = OptionalInt8Model(value: nil)
        _testDecode(model: model, messagePack: .map([:]))
    }
    func testShouldDecodeOptionalInt16ModelWithEmptyMap() {
        let model = OptionalInt16Model(value: nil)
        _testDecode(model: model, messagePack: .map([:]))
    }
    func testShouldDecodeOptionalInt32ModelWithEmptyMap() {
        let model = OptionalInt32Model(value: nil)
        _testDecode(model: model, messagePack: .map([:]))
    }
    func testShouldDecodeOptionalInt64ModelWithEmptyMap() {
        let model = OptionalInt64Model(value: nil)
        _testDecode(model: model, messagePack: .map([:]))
    }
    func testShouldDecodeOptionalUIntModelWithEmptyMap() {
        let model = OptionalUIntModel(value: nil)
        _testDecode(model: model, messagePack: .map([:]))
    }
    func testShouldDecodeOptionalUInt8ModelWithEmptyMap() {
        let model = OptionalUInt8Model(value: nil)
        _testDecode(model: model, messagePack: .map([:]))
    }
    func testShouldDecodeOptionalUInt16ModelWithEmptyMap() {
        let model = OptionalUInt16Model(value: nil)
        _testDecode(model: model, messagePack: .map([:]))
    }
    func testShouldDecodeOptionalUInt32ModelWithEmptyMap() {
        let model = OptionalUInt32Model(value: nil)
        _testDecode(model: model, messagePack: .map([:]))
    }
    func testShouldDecodeOptionalUInt64ModelWithEmptyMap() {
        let model = OptionalUInt64Model(value: nil)
        _testDecode(model: model, messagePack: .map([:]))
    }
    func testShouldDecodeOptionalFloatModelWithEmptyMap() {
        let model = OptionalFloatModel(value: nil)
        _testDecode(model: model, messagePack: .map([:]))
    }
    func testShouldDecodeOptionalDoubleModelWithEmptyMap() {
        let model = OptionalDoubleModel(value: nil)
        _testDecode(model: model, messagePack: .map([:]))
    }
    func testShouldDecodeOptionalStringModelWithEmptyMap() {
        let model = OptionalStringModel(value: nil)
        _testDecode(model: model, messagePack: .map([:]))
    }
    func testShouldDecodeOptionalDataModelWithEmptyMap() {
        let model = OptionalDataModel(value: nil)
        _testDecode(model: model, messagePack: .map([:]))
    }
    func testShouldDecodeOptionalArrayModelWithEmptyMap() {
        let model = OptionalArrayModel(value: nil)
        _testDecode(model: model, messagePack: .map([:]))
    }
    func testShouldDecodeOptionalMapModelWithEmptyMap() {
        let model = OptionalMapModel(value: nil)
        _testDecode(model: model, messagePack: .map([:]))
    }
}

// MARK: - Models
extension MessagePackDecoderTests {
    
    func testShouldDecodeModel() {
        let model = Car.generate(seed: 42)
        _testDecode(model: model)
    }
    
    func testShouldDecodeNestedModel() {
        let model = CarShop.generate(seed: 42)
        _testDecode(model: model)
    }
    
    func testShouldDecodeOptionalModel() {
        let model = OptionalCar.generate(seed: 42)
        _testDecode(model: model)
    }
    
    func testShouldDecodeOptionalNestedModel() {
        let model = OptionalCarShop.generate(seed: 42)
        _testDecode(model: model)
    }
    
    func testShouldDecodeEmptyOptionalModel() {
        let model = OptionalCar.empty()
        _testDecode(model: model)
    }
    
    func testShouldDecodeEmptyOptionalNestedModel() {
        let model = OptionalCarShop.empty()
        _testDecode(model: model)
    }
    
    func testShouldDecodeOptionalNestedModelWithEmptyMap() {
        let model = OptionalCarShop.empty()
        _testDecode(model: model, messagePack: .map([:]))
    }
}

// MARK: - Utilities
extension MessagePackDecoderTests {
    
    private func _testDecode<T: Model>(model: T) {
        _testDecode(model: model, messagePack: model.encoded)
    }
    
    private func _testDecode<T: Decodable & Equatable>(model: T, messagePack: MessagePackValue) {
        do {
            let decoded = try decoder.decodeMessagePack(T.self, from: messagePack)
            XCTAssertEqual(decoded, model)
        } catch {
            XCTAssertNil(error)
        }
    }
}
