//
//  MessagePackEncoderTests.swift
//  MessagePackTests
//
//  Created by Andrew Eng on 21/2/18.
//

import Foundation
import XCTest
@testable import MessagePack

class MessagePackEncoderTests: XCTestCase {
    
    fileprivate var encoder: MessagePackEncoder!
    fileprivate var decoder: MessagePackDecoder!
    
    override func setUp() {
        super.setUp()
        encoder = MessagePackEncoder()
        decoder = MessagePackDecoder()
    }
    
    override func tearDown() {
        decoder = nil
        encoder = nil
        super.tearDown()
    }
}

// MARK: - SingleTypeModel
extension MessagePackEncoderTests {
    
    func testShouldEncodeBoolModel() {
        let model = BoolModel(value: true)
        _testEncode(model: model)
    }
    func testShouldEncodeIntModel() {
        let model = IntModel(value: -42)
        _testEncode(model: model)
    }
    func testShouldEncodeInt8Model() {
        let model = Int8Model(value: -42)
        _testEncode(model: model)
    }
    func testShouldEncodeInt16Model() {
        let model = Int16Model(value: -42)
        _testEncode(model: model)
    }
    func testShouldEncodeInt32Model() {
        let model = Int32Model(value: -42)
        _testEncode(model: model)
    }
    func testShouldEncodeInt64Model() {
        let model = Int64Model(value: -42)
        _testEncode(model: model)
    }
    func testShouldEncodeUIntModel() {
        let model = UIntModel(value: 42)
        _testEncode(model: model)
    }
    func testShouldEncodeUInt8Model() {
        let model = UInt8Model(value: 42)
        _testEncode(model: model)
    }
    func testShouldEncodeUInt16Model() {
        let model = UInt16Model(value: 42)
        _testEncode(model: model)
    }
    func testShouldEncodeUInt32Model() {
        let model = UInt32Model(value: 42)
        _testEncode(model: model)
    }
    func testShouldEncodeUInt64Model() {
        let model = UInt64Model(value: 42)
        _testEncode(model: model)
    }
    func testShouldEncodeFloatModel() {
        let model = FloatModel(value: 3.14)
        _testEncode(model: model)
    }
    func testShouldEncodeDoubleModel() {
        let model = DoubleModel(value: 3.14)
        _testEncode(model: model)
    }
    func testShouldEncodeStringModel() {
        let model = StringModel(value: "a")
        _testEncode(model: model)
    }
    func testShouldEncodeDataModel() {
        let model = DataModel(value: Data(bytes: [0x42, 0x43, 0x44]))
        _testEncode(model: model)
    }
    func testShouldEncodeArrayModel() {
        let model = ArrayModel(value: ["a", "b", "c"])
        _testEncode(model: model)
    }
    func testShouldEncodeMapModel() {
        let model = MapModel(value: ["a": 42, "b": 43])
        _testEncode(model: model)
    }
}

// MARK: - SingleOptionalTypeModel
extension MessagePackEncoderTests {
    
    func testShouldEncodeOptionalBoolModel() {
        let model = OptionalBoolModel(value: true)
        _testEncode(model: model)
    }
    func testShouldEncodeOptionalIntModel() {
        let model = OptionalIntModel(value: -42)
        _testEncode(model: model)
    }
    func testShouldEncodeOptionalInt8Model() {
        let model = OptionalInt8Model(value: -42)
        _testEncode(model: model)
    }
    func testShouldEncodeOptionalInt16Model() {
        let model = OptionalInt16Model(value: -42)
        _testEncode(model: model)
    }
    func testShouldEncodeOptionalInt32Model() {
        let model = OptionalInt32Model(value: -42)
        _testEncode(model: model)
    }
    func testShouldEncodeOptionalInt64Model() {
        let model = OptionalInt64Model(value: -42)
        _testEncode(model: model)
    }
    func testShouldEncodeOptionalUIntModel() {
        let model = OptionalUIntModel(value: 42)
        _testEncode(model: model)
    }
    func testShouldEncodeOptionalUInt8Model() {
        let model = OptionalUInt8Model(value: 42)
        _testEncode(model: model)
    }
    func testShouldEncodeOptionalUInt16Model() {
        let model = OptionalUInt16Model(value: 42)
        _testEncode(model: model)
    }
    func testShouldEncodeOptionalUInt32Model() {
        let model = OptionalUInt32Model(value: 42)
        _testEncode(model: model)
    }
    func testShouldEncodeOptionalUInt64Model() {
        let model = OptionalUInt64Model(value: 42)
        _testEncode(model: model)
    }
    func testShouldEncodeOptionalFloatModel() {
        let model = OptionalFloatModel(value: 3.14)
        _testEncode(model: model)
    }
    func testShouldEncodeOptionalDoubleModel() {
        let model = OptionalDoubleModel(value: 3.14)
        _testEncode(model: model)
    }
    func testShouldEncodeOptionalStringModel() {
        let model = OptionalStringModel(value: "a")
        _testEncode(model: model)
    }
    func testShouldEncodeOptionalDataModel() {
        let model = OptionalDataModel(value: Data(bytes: [0x42, 0x43, 0x44]))
        _testEncode(model: model)
    }
    func testShouldEncodeOptionalArrayModel() {
        let model = OptionalArrayModel(value: ["a", "b", "c"])
        _testEncode(model: model)
    }
    func testShouldEncodeOptionalMapModel() {
        let model = OptionalMapModel(value: ["a": 42, "b": 43])
        _testEncode(model: model)
    }
    
    // MARK: Empty
    
    func testShouldEncodeEmptyOptionalBoolModel() {
        let model = OptionalBoolModel(value: nil)
        _testEncode(model: model)
    }
    func testShouldEncodeEmptyOptionalIntModel() {
        let model = OptionalIntModel(value: nil)
        _testEncode(model: model)
    }
    func testShouldEncodeEmptyOptionalInt8Model() {
        let model = OptionalInt8Model(value: nil)
        _testEncode(model: model)
    }
    func testShouldEncodeEmptyOptionalInt16Model() {
        let model = OptionalInt16Model(value: nil)
        _testEncode(model: model)
    }
    func testShouldEncodeEmptyOptionalInt32Model() {
        let model = OptionalInt32Model(value: nil)
        _testEncode(model: model)
    }
    func testShouldEncodeEmptyOptionalInt64Model() {
        let model = OptionalInt64Model(value: nil)
        _testEncode(model: model)
    }
    func testShouldEncodeEmptyOptionalUIntModel() {
        let model = OptionalUIntModel(value: nil)
        _testEncode(model: model)
    }
    func testShouldEncodeEmptyOptionalUInt8Model() {
        let model = OptionalUInt8Model(value: nil)
        _testEncode(model: model)
    }
    func testShouldEncodeEmptyOptionalUInt16Model() {
        let model = OptionalUInt16Model(value: nil)
        _testEncode(model: model)
    }
    func testShouldEncodeEmptyOptionalUInt32Model() {
        let model = OptionalUInt32Model(value: nil)
        _testEncode(model: model)
    }
    func testShouldEncodeEmptyOptionalUInt64Model() {
        let model = OptionalUInt64Model(value: nil)
        _testEncode(model: model)
    }
    func testShouldEncodeEmptyOptionalFloatModel() {
        let model = OptionalFloatModel(value: nil)
        _testEncode(model: model)
    }
    func testShouldEncodeEmptyOptionalDoubleModel() {
        let model = OptionalDoubleModel(value: nil)
        _testEncode(model: model)
    }
    func testShouldEncodeEmptyOptionalStringModel() {
        let model = OptionalStringModel(value: nil)
        _testEncode(model: model)
    }
    func testShouldEncodeEmptyOptionalDataModel() {
        let model = OptionalDataModel(value: nil)
        _testEncode(model: model)
    }
    func testShouldEncodeEmptyOptionalArrayModel() {
        let model = OptionalArrayModel(value: nil)
        _testEncode(model: model)
    }
    func testShouldEncodeEmptyOptionalMapModel() {
        let model = OptionalMapModel(value: nil)
        _testEncode(model: model)
    }
}

// MARK: - SingleOptionalTypeModel ignore key with nil value
extension MessagePackEncoderTests {
    
    func testShouldNotIgnoreKeyForOptionalBoolModel() {
        let model = OptionalBoolModel(value: true)
        _testEncodeIgnoringKeysWithNilValue(model: model)
    }
    func testShouldNotIgnoreKeyForOptionalIntModel() {
        let model = OptionalIntModel(value: -42)
        _testEncodeIgnoringKeysWithNilValue(model: model)
    }
    func testShouldNotIgnoreKeyForOptionalInt8Model() {
        let model = OptionalInt8Model(value: -42)
        _testEncodeIgnoringKeysWithNilValue(model: model)
    }
    func testShouldNotIgnoreKeyForOptionalInt16Model() {
        let model = OptionalInt16Model(value: -42)
        _testEncodeIgnoringKeysWithNilValue(model: model)
    }
    func testShouldNotIgnoreKeyForOptionalInt32Model() {
        let model = OptionalInt32Model(value: -42)
        _testEncodeIgnoringKeysWithNilValue(model: model)
    }
    func testShouldNotIgnoreKeyForOptionalInt64Model() {
        let model = OptionalInt64Model(value: -42)
        _testEncodeIgnoringKeysWithNilValue(model: model)
    }
    func testShouldNotIgnoreKeyForOptionalUIntModel() {
        let model = OptionalUIntModel(value: 42)
        _testEncodeIgnoringKeysWithNilValue(model: model)
    }
    func testShouldNotIgnoreKeyForOptionalUInt8Model() {
        let model = OptionalUInt8Model(value: 42)
        _testEncodeIgnoringKeysWithNilValue(model: model)
    }
    func testShouldNotIgnoreKeyForOptionalUInt16Model() {
        let model = OptionalUInt16Model(value: 42)
        _testEncodeIgnoringKeysWithNilValue(model: model)
    }
    func testShouldNotIgnoreKeyForOptionalUInt32Model() {
        let model = OptionalUInt32Model(value: 42)
        _testEncodeIgnoringKeysWithNilValue(model: model)
    }
    func testShouldNotIgnoreKeyForOptionalUInt64Model() {
        let model = OptionalUInt64Model(value: 42)
        _testEncodeIgnoringKeysWithNilValue(model: model)
    }
    func testShouldNotIgnoreKeyForOptionalFloatModel() {
        let model = OptionalFloatModel(value: 3.14)
        _testEncodeIgnoringKeysWithNilValue(model: model)
    }
    func testShouldNotIgnoreKeyForOptionalDoubleModel() {
        let model = OptionalDoubleModel(value: 3.14)
        _testEncodeIgnoringKeysWithNilValue(model: model)
    }
    func testShouldNotIgnoreKeyForOptionalStringModel() {
        let model = OptionalStringModel(value: "a")
        _testEncodeIgnoringKeysWithNilValue(model: model)
    }
    func testShouldNotIgnoreKeyForOptionalDataModel() {
        let model = OptionalDataModel(value: Data(bytes: [0x42, 0x43, 0x44]))
        _testEncodeIgnoringKeysWithNilValue(model: model)
    }
    func testShouldNotIgnoreKeyForOptionalArrayModel() {
        let model = OptionalArrayModel(value: ["a", "b", "c"])
        _testEncodeIgnoringKeysWithNilValue(model: model)
    }
    func testShouldNotIgnoreKeyForOptionalMapModel() {
        let model = OptionalMapModel(value: ["a": 42, "b": 43])
        _testEncodeIgnoringKeysWithNilValue(model: model)
    }
    
    // MARK: Empty
    
    func testShouldIgnoreKeyForEmptyOptionalBoolModel() {
        let model = OptionalBoolModel(value: nil)
        _testEncodeIgnoringKeysWithNilValue(model: model)
    }
    func testShouldIgnoreKeyForEmptyOptionalIntModel() {
        let model = OptionalIntModel(value: nil)
        _testEncodeIgnoringKeysWithNilValue(model: model)
    }
    func testShouldIgnoreKeyForEmptyOptionalInt8Model() {
        let model = OptionalInt8Model(value: nil)
        _testEncodeIgnoringKeysWithNilValue(model: model)
    }
    func testShouldIgnoreKeyForEmptyOptionalInt16Model() {
        let model = OptionalInt16Model(value: nil)
        _testEncodeIgnoringKeysWithNilValue(model: model)
    }
    func testShouldIgnoreKeyForEmptyOptionalInt32Model() {
        let model = OptionalInt32Model(value: nil)
        _testEncodeIgnoringKeysWithNilValue(model: model)
    }
    func testShouldIgnoreKeyForEmptyOptionalInt64Model() {
        let model = OptionalInt64Model(value: nil)
        _testEncodeIgnoringKeysWithNilValue(model: model)
    }
    func testShouldIgnoreKeyForEmptyOptionalUIntModel() {
        let model = OptionalUIntModel(value: nil)
        _testEncodeIgnoringKeysWithNilValue(model: model)
    }
    func testShouldIgnoreKeyForEmptyOptionalUInt8Model() {
        let model = OptionalUInt8Model(value: nil)
        _testEncodeIgnoringKeysWithNilValue(model: model)
    }
    func testShouldIgnoreKeyForEmptyOptionalUInt16Model() {
        let model = OptionalUInt16Model(value: nil)
        _testEncodeIgnoringKeysWithNilValue(model: model)
    }
    func testShouldIgnoreKeyForEmptyOptionalUInt32Model() {
        let model = OptionalUInt32Model(value: nil)
        _testEncodeIgnoringKeysWithNilValue(model: model)
    }
    func testShouldIgnoreKeyForEmptyOptionalUInt64Model() {
        let model = OptionalUInt64Model(value: nil)
        _testEncodeIgnoringKeysWithNilValue(model: model)
    }
    func testShouldIgnoreKeyForEmptyOptionalFloatModel() {
        let model = OptionalFloatModel(value: nil)
        _testEncodeIgnoringKeysWithNilValue(model: model)
    }
    func testShouldIgnoreKeyForEmptyOptionalDoubleModel() {
        let model = OptionalDoubleModel(value: nil)
        _testEncodeIgnoringKeysWithNilValue(model: model)
    }
    func testShouldIgnoreKeyForEmptyOptionalStringModel() {
        let model = OptionalStringModel(value: nil)
        _testEncodeIgnoringKeysWithNilValue(model: model)
    }
    func testShouldIgnoreKeyForEmptyOptionalDataModel() {
        let model = OptionalDataModel(value: nil)
        _testEncodeIgnoringKeysWithNilValue(model: model)
    }
    func testShouldIgnoreKeyForEmptyOptionalArrayModel() {
        let model = OptionalArrayModel(value: nil)
        _testEncodeIgnoringKeysWithNilValue(model: model)
    }
    func testShouldIgnoreKeyForEmptyOptionalMapModel() {
        let model = OptionalMapModel(value: nil)
        _testEncodeIgnoringKeysWithNilValue(model: model)
    }
}

// MARK: - Models
extension MessagePackEncoderTests {
    
    // MARK: Model
    
    func testShouldEncodeModel() {
        let model = Car.generate(seed: 42)
        _testEncode(model: model)
    }
    func testShouldEncodeOptionalModelWithValue() {
        let model = OptionalCar.generate(seed: 42)
        _testEncode(model: model)
    }
    func testShouldEncodeOptionalModelWithNil() {
        let model = OptionalCar.empty()
        _testEncode(model: model)
    }
    func testShouldNotIgnoreKeyForOptionalModel() {
        let model = OptionalCar.generate(seed: 42)
        _testEncodeIgnoringKeysWithNilValue(model: model)
    }
    func testShouldIgnoreKeyForEmptyOptionalModel() {
        let model = OptionalCar.empty()
        _testEncodeIgnoringKeysWithNilValue(model: model)
    }
    
    // MARK: Nested Model
    
    func testShouldEncodeNestedModel() {
        let model = CarShop.generate(seed: 42)
        _testEncode(model: model)
    }
    func testShouldEncodeOptionalNestedModelWithValue() {
        let model = OptionalCarShop.generate(seed: 42)
        _testEncode(model: model)
    }
    func testShouldEncodeOptionalNestedModelWithNil() {
        let model = OptionalCarShop.empty()
        _testEncode(model: model)
    }
    func testShouldNotIgnoreKeyForOptionalNestedModel() {
        let model = OptionalCarShop.generate(seed: 42)
        _testEncodeIgnoringKeysWithNilValue(model: model)
    }
    func testShouldIgnoreKeyForEmptyOptionalNestedModel() {
        let model = OptionalCarShop.empty()
        _testEncodeIgnoringKeysWithNilValue(model: model)
    }
}

// MAKR: - Round Trip
extension MessagePackEncoderTests {
    
    func testShouldRoundTripModel() {
        do {
            let model = CarShop.generate(seed: 42)
            let data = try encoder.encode(model)
            let decodedModel = try decoder.decode(CarShop.self, from: data)
            XCTAssertEqual(model, decodedModel)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func testShouldMultiStepRoundTripModel() {
        do {
            let model = CarShop.generate(seed: 42)
            let messagePack = try encoder.encodeToMessagePack(model)
            let data = try encoder.encodeMessagePack(messagePack)
            let decodedMessagePack = try decoder.decodeToMessagePack(from: data)
            let decodedModel = try decoder.decodeMessagePack(CarShop.self, from: decodedMessagePack)
            
            XCTAssertEqual(model, decodedModel)
        } catch {
            XCTAssertNil(error)
        }
    }
}

// MARK: - Utilities
extension MessagePackEncoderTests {
    
    fileprivate func _testEncode<T: Model>(model: T) {
        do {
            let encoded = try encoder.encodeToMessagePack(model)
            XCTAssertEqual(encoded, model.encoded)
        } catch {
            XCTAssertNil(error)
        }
    }
    
    fileprivate func _testEncodeIgnoringKeysWithNilValue<T: OptionalModel>(model: T) {
        do {
            encoder.keyedEncodingOptions = .ignoreKeysWithNilValue
            let encoded = try encoder.encodeToMessagePack(model)
            XCTAssertEqual(encoded, model.encodedIgnoringNil)
        } catch {
            XCTAssertNil(error)
        }
    }
}
