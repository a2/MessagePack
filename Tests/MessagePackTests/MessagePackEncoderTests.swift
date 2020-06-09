import Foundation
import XCTest
@testable import MessagePack

/**
 * The implementation of MessagePackEncoderTests heavily references `TestsJSONEncoder.swift`
 * from the Swift foundation library.
 *
 * - Note: See `MessagePackEncoder.swift`
 */

class MessagePackEncoderTests : XCTestCase {
    // MARK: - Encoding Top-Level Empty Types
    func testEncodingTopLevelEmptyStruct() {
        let empty = EmptyStruct()
        _testRoundTrip(of: empty, expectedData: _messagePackEmptyDictionary)
    }
    
    func testEncodingTopLevelEmptyClass() {
        let empty = EmptyClass()
        _testRoundTrip(of: empty, expectedData: _messagePackEmptyDictionary)
    }
    
    // MARK: - Encoding Top-Level Single-Value Types
    func testEncodingTopLevelSingleValueEnum() {
        _testRoundTrip(of: Switch.off)
        _testRoundTrip(of: Switch.on)
        
        _testRoundTrip(of: TopLevelWrapper(Switch.off))
        _testRoundTrip(of: TopLevelWrapper(Switch.on))
    }
    
    func testEncodingTopLevelSingleValueStruct() {
        _testRoundTrip(of: Timestamp(3141592653))
        _testRoundTrip(of: TopLevelWrapper(Timestamp(3141592653)))
    }
    
    func testEncodingTopLevelSingleValueClass() {
        _testRoundTrip(of: Counter())
        _testRoundTrip(of: TopLevelWrapper(Counter()))
    }
    
    // MARK: - Encoding Top-Level Structured Types
    func testEncodingTopLevelStructuredStruct() {
        // Address is a struct type with multiple fields.
        let address = Address.testValue
        _testRoundTrip(of: address)
    }
    
    func testEncodingTopLevelStructuredClass() {
        // Person is a class with multiple fields.
        let person = Person.testValue
        _testRoundTrip(of: person)
    }
    
    func testEncodingTopLevelStructuredSingleStruct() {
        // Numbers is a struct which encodes as an array through a single value container.
        let numbers = Numbers.testValue
        _testRoundTrip(of: numbers)
    }
    
    func testEncodingTopLevelStructuredSingleClass() {
        // Mapping is a class which encodes as a dictionary through a single value container.
        let mapping = Mapping.testValue
        _testRoundTrip(of: mapping)
    }
    
    func testEncodingTopLevelDeepStructuredType() {
        // Company is a type with fields which are Codable themselves.
        let company = Company.testValue
        _testRoundTrip(of: company)
    }
    
    func testEncodingClassWhichSharesEncoderWithSuper() {
        // Employee is a type which shares its encoder & decoder with its superclass, Person.
        let employee = Employee.testValue
        _testRoundTrip(of: employee)
    }
    
    func testEncodingTopLevelNullableType() {
        // EnhancedBool is a type which encodes either as a Bool or as nil.
        _testRoundTrip(of: EnhancedBool.true)
        _testRoundTrip(of: EnhancedBool.false)
        _testRoundTrip(of: EnhancedBool.fileNotFound)
        
        _testRoundTrip(of: TopLevelWrapper(EnhancedBool.true))
        _testRoundTrip(of: TopLevelWrapper(EnhancedBool.false))
        _testRoundTrip(of: TopLevelWrapper(EnhancedBool.fileNotFound))
    }
    
    // MARK: - Date Strategy Tests
    func testEncodingDate() {
        _testRoundTrip(of: Date())
        _testRoundTrip(of: TopLevelWrapper(Date()))
        _testRoundTrip(of: OptionalTopLevelWrapper(Date()))
    }
    
    // MARK: - Data Strategy Tests
    
    func testEncodingData() {
        let data = Data(bytes: [0xDE, 0xAD, 0xBE, 0xEF])
        
        _testRoundTrip(of: data)
        _testRoundTrip(of: TopLevelWrapper(data))
        _testRoundTrip(of: OptionalTopLevelWrapper(data))
    }
    
    // MARK: - Encoder Features
    func testNestedContainerCodingPaths() {
        let encoder = MessagePackEncoder()
        do {
            let _ = try encoder.encode(NestedContainersTestType())
        } catch {
            XCTAssert(false, "Caught error during encoding nested container types: \(error)")
        }
    }
    
    func testSuperEncoderCodingPaths() {
        let encoder = MessagePackEncoder()
        do {
            let _ = try encoder.encode(NestedContainersTestType(testSuperEncoder: true))
        } catch {
            XCTAssert(false, "Caught error during encoding nested container types: \(error)")
        }
    }
    
    // MARK: - Helper Functions
    private var _messagePackEmptyDictionary: Data {
        return Data([0x80])
    }
    
    private func _testRoundTrip<T>(of value: T, expectedData data: Data? = nil) where T : Codable, T : Equatable {
        _testSingleStepRoundTrip(of: value, expectedData: data)
        _testMultiStepRoundTrip(of: value, expectedData: data)
    }
    
    private func _testSingleStepRoundTrip<T>(of value: T, expectedData data: Data? = nil) where T : Codable, T : Equatable {
        
        var payload: Data! = nil
        do {
            let encoder = MessagePackEncoder()
            payload = try encoder.encode(value)
        } catch {
            XCTAssert(false, "Failed to encode \(T.self) to data: \(error)")
        }
        
        if let expectedData = data {
            XCTAssertEqual(expectedData, payload, "Produced data not identical to expected data.")
        }
        
        do {
            let decoder = MessagePackDecoder()
            let decoded = try decoder.decode(T.self, from: payload)
            XCTAssertEqual(decoded, value, "\(T.self) did not round-trip to an equal value.")
        } catch {
            XCTAssert(false, "Failed to decode \(T.self) from data: \(error)")
        }
    }
    
    private func _testMultiStepRoundTrip<T>(of value: T, expectedData data: Data? = nil) where T : Codable, T : Equatable {

        let encoder = MessagePackEncoder()
        let decoder = MessagePackDecoder()
        
        var messagePack: MessagePackValue! = nil
        do {
            messagePack = try encoder.messagePack(with: value)
        } catch {
            XCTAssert(false, "Failed to encode \(T.self) to MessagePack: \(error)")
        }
        
        var payload: Data! = nil
        do {
            payload = try encoder.encode(messagePack: messagePack)
        } catch {
            XCTAssert(false, "Failed to encode \(T.self) to data: \(error)")
        }
        
        if let expectedData = data {
            XCTAssertEqual(expectedData, payload, "Produced data not identical to expected data.")
        }
        
        var decodedMessagePack: MessagePackValue = nil
        do {
            decodedMessagePack = try decoder.messagePack(with: payload)
            XCTAssertEqual(decodedMessagePack, messagePack, "Conversion from Data to MessagePack did not round-trip to an equal value.")
        } catch {
            XCTAssert(false, "Failed to decode MessagePack from data: \(error)")
        }
        
        do {
            let decoded = try decoder.decode(T.self, from: decodedMessagePack)
            XCTAssertEqual(decoded, value, "Conversion from MessagePack to \(T.self) did not round-trip to an equal value.")
        } catch {
            XCTAssert(false, "Failed to decode \(T.self) from MessagePack: \(error)")
        }
    }
}

// MARK: - Helper Global Functions
func XCTAssertEqualPaths(_ lhs: [CodingKey], _ rhs: [CodingKey], _ prefix: String) {
    if lhs.count != rhs.count {
        XCTAssert(false, "\(prefix) [CodingKey].count mismatch: \(lhs.count) != \(rhs.count)")
        return
    }
    
    for (key1, key2) in zip(lhs, rhs) {
        switch (key1.intValue, key2.intValue) {
        case (.none, .none): break
        case (.some(let i1), .none):
            XCTAssert(false, "\(prefix) CodingKey.intValue mismatch: \(type(of: key1))(\(i1)) != nil")
            return
        case (.none, .some(let i2)):
            XCTAssert(false, "\(prefix) CodingKey.intValue mismatch: nil != \(type(of: key2))(\(i2))")
            return
        case (.some(let i1), .some(let i2)):
            guard i1 == i2 else {
                XCTAssert(false, "\(prefix) CodingKey.intValue mismatch: \(type(of: key1))(\(i1)) != \(type(of: key2))(\(i2))")
                return
            }
            
            break
        }
        
        XCTAssertEqual(key1.stringValue, key2.stringValue, "\(prefix) CodingKey.stringValue mismatch: \(type(of: key1))('\(key1.stringValue)') != \(type(of: key2))('\(key2.stringValue)')")
    }
}

// MARK: - Test Types
/* FIXME: Import from %S/Inputs/Coding/SharedTypes.swift somehow. */

// MARK: - Empty Types
fileprivate struct EmptyStruct : Codable, Equatable {
    static func ==(_ lhs: EmptyStruct, _ rhs: EmptyStruct) -> Bool {
        return true
    }
}

fileprivate class EmptyClass : Codable, Equatable {
    static func ==(_ lhs: EmptyClass, _ rhs: EmptyClass) -> Bool {
        return true
    }
}

// MARK: - Single-Value Types
/// A simple on-off switch type that encodes as a single Bool value.
fileprivate enum Switch : Codable {
    case off
    case on
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        switch try container.decode(Bool.self) {
        case false: self = .off
        case true:  self = .on
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .off: try container.encode(false)
        case .on:  try container.encode(true)
        }
    }
}

/// A simple timestamp type that encodes as a single Double value.
fileprivate struct Timestamp : Codable, Equatable {
    let value: Double
    
    init(_ value: Double) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode(Double.self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.value)
    }
    
    static func ==(_ lhs: Timestamp, _ rhs: Timestamp) -> Bool {
        return lhs.value == rhs.value
    }
}

/// A simple referential counter type that encodes as a single Int value.
fileprivate final class Counter : Codable, Equatable {
    var count: Int = 0
    
    init() {}
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        count = try container.decode(Int.self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.count)
    }
    
    static func ==(_ lhs: Counter, _ rhs: Counter) -> Bool {
        return lhs === rhs || lhs.count == rhs.count
    }
}

// MARK: - Structured Types
/// A simple address type that encodes as a dictionary of values.
fileprivate struct Address : Codable, Equatable {
    let street: String
    let city: String
    let state: String
    let zipCode: Int
    let country: String
    
    init(street: String, city: String, state: String, zipCode: Int, country: String) {
        self.street = street
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.country = country
    }
    
    static func ==(_ lhs: Address, _ rhs: Address) -> Bool {
        return lhs.street == rhs.street &&
            lhs.city == rhs.city &&
            lhs.state == rhs.state &&
            lhs.zipCode == rhs.zipCode &&
            lhs.country == rhs.country
    }
    
    static var testValue: Address {
        return Address(street: "1 Infinite Loop",
                       city: "Cupertino",
                       state: "CA",
                       zipCode: 95014,
                       country: "United States")
    }
}

/// A simple person class that encodes as a dictionary of values.
fileprivate class Person : Codable, Equatable {
    let name: String
    let email: String
    let website: URL?
    
    init(name: String, email: String, website: URL? = nil) {
        self.name = name
        self.email = email
        self.website = website
    }
    
    private enum CodingKeys : String, CodingKey {
        case name
        case email
        case website
    }
    
    // FIXME: Remove when subclasses (Employee) are able to override synthesized conformance.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        email = try container.decode(String.self, forKey: .email)
        website = try container.decodeIfPresent(URL.self, forKey: .website)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
        try container.encodeIfPresent(website, forKey: .website)
    }
    
    func isEqual(_ other: Person) -> Bool {
        return self.name == other.name &&
            self.email == other.email &&
            self.website == other.website
    }
    
    static func ==(_ lhs: Person, _ rhs: Person) -> Bool {
        return lhs.isEqual(rhs)
    }
    
    class var testValue: Person {
        return Person(name: "Johnny Appleseed", email: "appleseed@apple.com")
    }
}

/// A class which shares its encoder and decoder with its superclass.
fileprivate class Employee : Person {
    let id: Int
    
    init(name: String, email: String, website: URL? = nil, id: Int) {
        self.id = id
        super.init(name: name, email: email, website: website)
    }
    
    enum CodingKeys : String, CodingKey {
        case id
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try super.encode(to: encoder)
    }
    
    override func isEqual(_ other: Person) -> Bool {
        if let employee = other as? Employee {
            guard self.id == employee.id else { return false }
        }
        
        return super.isEqual(other)
    }
    
    override class var testValue: Employee {
        return Employee(name: "Johnny Appleseed", email: "appleseed@apple.com", id: 42)
    }
}

/// A simple company struct which encodes as a dictionary of nested values.
fileprivate struct Company : Codable, Equatable {
    let address: Address
    var employees: [Employee]
    
    init(address: Address, employees: [Employee]) {
        self.address = address
        self.employees = employees
    }
    
    static func ==(_ lhs: Company, _ rhs: Company) -> Bool {
        return lhs.address == rhs.address && lhs.employees == rhs.employees
    }
    
    static var testValue: Company {
        return Company(address: Address.testValue, employees: [Employee.testValue])
    }
}

/// An enum type which decodes from Bool?.
fileprivate enum EnhancedBool : Codable {
    case `true`
    case `false`
    case fileNotFound
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .fileNotFound
        } else {
            let value = try container.decode(Bool.self)
            self = value ? .true : .false
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .true: try container.encode(true)
        case .false: try container.encode(false)
        case .fileNotFound: try container.encodeNil()
        }
    }
}

/// A type which encodes as an array directly through a single value container.
struct Numbers : Codable, Equatable {
    let values = [4, 8, 15, 16, 23, 42]
    
    init() {}
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let decodedValues = try container.decode([Int].self)
        guard decodedValues == values else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "The Numbers are wrong!"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(values)
    }
    
    static func ==(_ lhs: Numbers, _ rhs: Numbers) -> Bool {
        return lhs.values == rhs.values
    }
    
    static var testValue: Numbers {
        return Numbers()
    }
}

/// A type which encodes as a dictionary directly through a single value container.
fileprivate final class Mapping : Codable, Equatable {
    let values: [String : URL]
    
    init(values: [String : URL]) {
        self.values = values
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        values = try container.decode([String : URL].self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(values)
    }
    
    static func ==(_ lhs: Mapping, _ rhs: Mapping) -> Bool {
        return lhs === rhs || lhs.values == rhs.values
    }
    
    static var testValue: Mapping {
        return Mapping(values: ["Apple": URL(string: "http://apple.com")!,
                                "localhost": URL(string: "http://127.0.0.1")!])
    }
}

struct NestedContainersTestType : Encodable {
    let testSuperEncoder: Bool
    
    init(testSuperEncoder: Bool = false) {
        self.testSuperEncoder = testSuperEncoder
    }
    
    enum TopLevelCodingKeys : Int, CodingKey {
        case a
        case b
        case c
    }
    
    enum IntermediateCodingKeys : Int, CodingKey {
        case one
        case two
    }
    
    func encode(to encoder: Encoder) throws {
        if self.testSuperEncoder {
            var topLevelContainer = encoder.container(keyedBy: TopLevelCodingKeys.self)
            XCTAssertEqualPaths(encoder.codingPath, [], "Top-level Encoder's codingPath changed.")
            XCTAssertEqualPaths(topLevelContainer.codingPath, [], "New first-level keyed container has non-empty codingPath.")
            
            let superEncoder = topLevelContainer.superEncoder(forKey: .a)
            XCTAssertEqualPaths(encoder.codingPath, [], "Top-level Encoder's codingPath changed.")
            XCTAssertEqualPaths(topLevelContainer.codingPath, [], "First-level keyed container's codingPath changed.")
            XCTAssertEqualPaths(superEncoder.codingPath, [TopLevelCodingKeys.a], "New superEncoder had unexpected codingPath.")
            _testNestedContainers(in: superEncoder, baseCodingPath: [TopLevelCodingKeys.a])
        } else {
            _testNestedContainers(in: encoder, baseCodingPath: [])
        }
    }
    
    func _testNestedContainers(in encoder: Encoder, baseCodingPath: [CodingKey]) {
        XCTAssertEqualPaths(encoder.codingPath, baseCodingPath, "New encoder has non-empty codingPath.")
        
        // codingPath should not change upon fetching a non-nested container.
        var firstLevelContainer = encoder.container(keyedBy: TopLevelCodingKeys.self)
        XCTAssertEqualPaths(encoder.codingPath, baseCodingPath, "Top-level Encoder's codingPath changed.")
        XCTAssertEqualPaths(firstLevelContainer.codingPath, baseCodingPath, "New first-level keyed container has non-empty codingPath.")
        
        // Nested Keyed Container
        do {
            // Nested container for key should have a new key pushed on.
            var secondLevelContainer = firstLevelContainer.nestedContainer(keyedBy: IntermediateCodingKeys.self, forKey: .a)
            XCTAssertEqualPaths(encoder.codingPath, baseCodingPath, "Top-level Encoder's codingPath changed.")
            XCTAssertEqualPaths(firstLevelContainer.codingPath, baseCodingPath, "First-level keyed container's codingPath changed.")
            XCTAssertEqualPaths(secondLevelContainer.codingPath, baseCodingPath + [TopLevelCodingKeys.a], "New second-level keyed container had unexpected codingPath.")
            
            // Inserting a keyed container should not change existing coding paths.
            let thirdLevelContainerKeyed = secondLevelContainer.nestedContainer(keyedBy: IntermediateCodingKeys.self, forKey: .one)
            XCTAssertEqualPaths(encoder.codingPath, baseCodingPath, "Top-level Encoder's codingPath changed.")
            XCTAssertEqualPaths(firstLevelContainer.codingPath, baseCodingPath, "First-level keyed container's codingPath changed.")
            XCTAssertEqualPaths(secondLevelContainer.codingPath, baseCodingPath + [TopLevelCodingKeys.a], "Second-level keyed container's codingPath changed.")
            XCTAssertEqualPaths(thirdLevelContainerKeyed.codingPath, baseCodingPath + [TopLevelCodingKeys.a, IntermediateCodingKeys.one], "New third-level keyed container had unexpected codingPath.")
            
            // Inserting an unkeyed container should not change existing coding paths.
            let thirdLevelContainerUnkeyed = secondLevelContainer.nestedUnkeyedContainer(forKey: .two)
            XCTAssertEqualPaths(encoder.codingPath, baseCodingPath + [], "Top-level Encoder's codingPath changed.")
            XCTAssertEqualPaths(firstLevelContainer.codingPath, baseCodingPath + [], "First-level keyed container's codingPath changed.")
            XCTAssertEqualPaths(secondLevelContainer.codingPath, baseCodingPath + [TopLevelCodingKeys.a], "Second-level keyed container's codingPath changed.")
            XCTAssertEqualPaths(thirdLevelContainerUnkeyed.codingPath, baseCodingPath + [TopLevelCodingKeys.a, IntermediateCodingKeys.two], "New third-level unkeyed container had unexpected codingPath.")
        }
        
        // Nested Unkeyed Container
        do {
            // Nested container for key should have a new key pushed on.
            var secondLevelContainer = firstLevelContainer.nestedUnkeyedContainer(forKey: .b)
            XCTAssertEqualPaths(encoder.codingPath, baseCodingPath, "Top-level Encoder's codingPath changed.")
            XCTAssertEqualPaths(firstLevelContainer.codingPath, baseCodingPath, "First-level keyed container's codingPath changed.")
            XCTAssertEqualPaths(secondLevelContainer.codingPath, baseCodingPath + [TopLevelCodingKeys.b], "New second-level keyed container had unexpected codingPath.")
            
            // Appending a keyed container should not change existing coding paths.
            let thirdLevelContainerKeyed = secondLevelContainer.nestedContainer(keyedBy: IntermediateCodingKeys.self)
            XCTAssertEqualPaths(encoder.codingPath, baseCodingPath, "Top-level Encoder's codingPath changed.")
            XCTAssertEqualPaths(firstLevelContainer.codingPath, baseCodingPath, "First-level keyed container's codingPath changed.")
            XCTAssertEqualPaths(secondLevelContainer.codingPath, baseCodingPath + [TopLevelCodingKeys.b], "Second-level unkeyed container's codingPath changed.")
            XCTAssertEqualPaths(thirdLevelContainerKeyed.codingPath, baseCodingPath + [TopLevelCodingKeys.b, _TestKey(index: 0)], "New third-level keyed container had unexpected codingPath.")
            
            // Appending an unkeyed container should not change existing coding paths.
            let thirdLevelContainerUnkeyed = secondLevelContainer.nestedUnkeyedContainer()
            XCTAssertEqualPaths(encoder.codingPath, baseCodingPath, "Top-level Encoder's codingPath changed.")
            XCTAssertEqualPaths(firstLevelContainer.codingPath, baseCodingPath, "First-level keyed container's codingPath changed.")
            XCTAssertEqualPaths(secondLevelContainer.codingPath, baseCodingPath + [TopLevelCodingKeys.b], "Second-level unkeyed container's codingPath changed.")
            XCTAssertEqualPaths(thirdLevelContainerUnkeyed.codingPath, baseCodingPath + [TopLevelCodingKeys.b, _TestKey(index: 1)], "New third-level unkeyed container had unexpected codingPath.")
        }
    }
}

// MARK: - Helper Types

/// A key type which can take on any string or integer value.
/// This needs to mirror _MessagePackKey.
fileprivate struct _TestKey : CodingKey {
    var stringValue: String
    var intValue: Int?
    
    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
    
    init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
    
    init(index: Int) {
        self.stringValue = "Index \(index)"
        self.intValue = index
    }
}

/// Wraps a type T so that it can be encoded at the top level of a payload.
fileprivate struct TopLevelWrapper<T> : Codable, Equatable where T : Codable, T : Equatable {
    let value: T
    
    init(_ value: T) {
        self.value = value
    }
    
    static func ==(_ lhs: TopLevelWrapper<T>, _ rhs: TopLevelWrapper<T>) -> Bool {
        return lhs.value == rhs.value
    }
}

/// Wraps a type T (as T?) so that it can be encoded at the top level of a payload.
fileprivate struct OptionalTopLevelWrapper<T> : Codable, Equatable where T : Codable, T : Equatable {
    let value: T?
    
    init(_ value: T) {
        self.value = value
    }
    
    // Provide an implementation of Codable to encode(forKey:) instead of encodeIfPresent(forKey:).
    private enum CodingKeys : String, CodingKey {
        case value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decode(T?.self, forKey: .value)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
    }
    
    static func ==(_ lhs: OptionalTopLevelWrapper<T>, _ rhs: OptionalTopLevelWrapper<T>) -> Bool {
        return lhs.value == rhs.value
    }
}
