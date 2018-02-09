import Foundation
import XCTest
@testable import MessagePack

class CodableTests: XCTestCase {
    static var allTests = {
        return [
            ("testPlanet", testPlanet),
            ]
    }()
    
    
    func testPlanet() {
        
        let mars = Planet.mars
        let expected = MessagePackValue.string("mars")
        
        let converted = try? CodableConverter().encode(mars)
        
        guard converted != nil else {
            XCTFail("Converting mars failed")
            return
        }
        
        XCTAssert(expected == converted, "Converted value (\(String(describing: converted)) and expected value (\(expected)) didn't match.")
        
        let unconverted = try? CodableConverter().decode(toType: Planet.self, from: converted!)
        
        guard converted != nil else {
            XCTFail("Unconverting mars failed")
            return
        }
        
        XCTAssert(mars == unconverted, "Unconverted value (\(String(describing: unconverted)) and expected value (\(mars)) didn't match.")
        
    }
    
    enum Planet: String, Codable {
        case earth
        case mars
        case venus
        case mercur
    }
    
}

