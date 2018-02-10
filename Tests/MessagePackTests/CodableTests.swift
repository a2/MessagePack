import Foundation
import XCTest
@testable import MessagePack

class CodableTests: XCTestCase {
    static var allTests = {
        return [
            ("testDirectlyConverting", testDirectlyConverting),
            ("testComplex", testComplex)
            ]
    }()
    
    func testDirectlyConverting() {
        
        let mars = Planet.mars
        let expected = MessagePackValue.string("mars")
        
        roundWayConvert(value: mars, expected: expected)
        
    }
    
    func testNonstrictNumberConversion() {
        
        // this test shows, that a loosy converion of Double values
        // is done implicitly.
        // A small change in ConvenienceProperties changes this.
        
        /*
         // this float value is not convertible to Float
         let floatValue = Float(exactly: 3.565761343565446)
         */
        
        let testValue = MessagePackValue.map([.string("brightness"): .double(3.565761343565446),
                                              .string("diameter"): .float(31.5),
                                              .string("mass"): .float(3.846e26),
                                              .string("name"): .string("fictional sun")])
        
        let sun = try? MessagePackValueSerialization().decode(toType: Sun.self, from: testValue)
        XCTAssert(sun != nil, "Number conversion didn't succeed")
        
    }
    
    func testComplex() {
        
        let sunsystem = Sunsystem(name: "the sun system",
                                  sun: Sun(brightness: 1.0, diameter: 31.5, mass: 3.846e26, name: "the sun"),
                                  planets: .mercur, .venus, .earth, .mars, .jupiter, .saturn, .uranus, .neptun)
        
        let expected = MessagePackValue.map([.string("name"): .string("the sun system"),
                                             .string("sun"): .map([.string("brightness"): .float(1.0),
                                                                   .string("diameter"): .float(31.5),
                                                                   .string("mass"): .float(3.846e26),
                                                                   .string("name"): .string("the sun")]),
                                             .string("planets"): .array([.string("mercur"), .string("venus"),
                                                                         .string("earth"), .string("mars"),
                                                                         .string("jupiter"), .string("saturn"),
                                                                         .string("uranus"), .string("neptun")])
            ])
        
        roundWayConvert(value: sunsystem, expected: expected)
        
    }
    
    fileprivate func roundWayConvert<T>(value: T, expected: MessagePackValue) where T: Codable, T: Equatable {
        
        let converted = try? MessagePackValueSerialization().encode(value)
        
        guard converted != nil else {
            XCTFail("Converting value (\(value)) failed")
            return
        }
        
        XCTAssert(expected == converted!, "Converted value (\(converted!)) and expected value (\(expected)) didn't match.")
        
        let unconverted = try? MessagePackValueSerialization().decode(toType: T.self, from: converted!)
        
        guard converted != nil else {
            XCTFail("Unconverting value (\(value)) failed")
            return
        }
        
        XCTAssert(value == unconverted!, "Unconverted value (\(unconverted!)) and expected value (\(value)) didn't match.")
        
    }
    
    // MARK: - tests structs and enums
    
    enum Planet: String, Codable {
        case mercur
        case venus
        case earth
        case mars
        case jupiter
        case saturn
        case uranus
        case neptun
    }
    
    struct Sun: Codable, Equatable {
        
        let brightness: Float
        let diameter: Float
        let mass: Float
        
        let name: String
        
        init(brightness: Float, diameter: Float, mass: Float, name: String) {
            self.brightness = brightness
            self.diameter = diameter
            self.mass = mass
            self.name = name
        }
        
        static func ==(lhs: CodableTests.Sun, rhs: CodableTests.Sun) -> Bool {
            return lhs.brightness == rhs.brightness && lhs.diameter == rhs.diameter && lhs.mass == rhs.mass && lhs.name == rhs.name
        }
        
    }
    
    struct Sunsystem: Codable, Equatable {
        
        let name: String
        let sun: Sun
        let planets: [Planet]
        
        init(name: String, sun: Sun, planets: Planet...) {
            self.name = name
            self.sun = sun
            self.planets = planets
        }
        
        static func ==(lhs: CodableTests.Sunsystem, rhs: CodableTests.Sunsystem) -> Bool {
            return lhs.name == rhs.name && lhs.sun == rhs.sun && lhs.planets == rhs.planets
        }
        
    }
    
}

