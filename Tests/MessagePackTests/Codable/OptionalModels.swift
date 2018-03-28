//
//  OptionalModels.swift
//  MessagePackTests
//
//  Created by Andrew Eng on 23/2/18.
//

import Foundation
@testable import MessagePack

struct OptionalCar: OptionalModel {
    let id: Data?
    let brand: String?
    let power: Double?
    
    static func ==(lhs: OptionalCar, rhs: OptionalCar) -> Bool {
        return lhs.id == rhs.id && lhs.brand == rhs.brand && lhs.power == rhs.power
    }
    
    var encoded: MessagePackValue {
        return .map([
            .string("id"): (id != nil ? MessagePackValue.binary(id!) : MessagePackValue.`nil`),
            .string("brand"): (brand != nil ? MessagePackValue.string(brand!) : MessagePackValue.`nil`),
            .string("power"): (power != nil ? MessagePackValue.double(power!) : MessagePackValue.`nil`)
            ])
    }
    
    var encodedIgnoringNil: MessagePackValue {
        var map = [MessagePackValue: MessagePackValue]()
        if let id = id { map[.string("id")] = MessagePackValue.binary(id) }
        if let brand = brand { map[.string("brand")] = MessagePackValue.string(brand) }
        if let power = power { map[.string("power")] = MessagePackValue.double(power) }
        return .map(map)
    }
    
    static func generate(seed: UInt8) -> OptionalCar {
        return OptionalCar(id: Data(bytes: [seed, seed + 1]), brand: "\(seed)", power: (3.14 * Double(seed)))
    }
    static func empty() -> OptionalCar {
        return OptionalCar(id: nil, brand: nil, power: nil)
    }
}


struct OptionalCarShop: OptionalModel {
    let car: OptionalCar?
    let carArray: [OptionalCar]?
    let carMap: [String: OptionalCar]?
    
    static func ==(lhs: OptionalCarShop, rhs: OptionalCarShop) -> Bool {
        if lhs.car != rhs.car {
            return false
        }
        
        if let lhsArray = lhs.carArray, let rhsArray = rhs.carArray {
            if lhsArray != rhsArray { return false }
        } else if lhs.carArray != nil || rhs.carArray != nil {
            return false
        }
        
        if let lhsMap = lhs.carMap, let rhsMap = rhs.carMap {
            if lhsMap != rhsMap { return false }
        } else if lhs.carMap != nil || rhs.carMap != nil {
            return false
        }
        
        return true
    }
    
    var encoded: MessagePackValue {
        
        let array: MessagePackValue
        if let carArray = carArray {
            array = .array(carArray.map({ $0.encoded }))
        } else {
            array = .`nil`
        }
        
        let map: MessagePackValue
        if let carMap = carMap {
            var m = [MessagePackValue: MessagePackValue]()
            carMap.forEach({ m[.string($0)] = $1.encoded })
            map = .map(m)
        } else {
            map = .`nil`
        }
        
        return .map([
            .string("car"): car?.encoded ?? .`nil`,
            .string("carArray"): array,
            .string("carMap"): map
            ])
    }
    
    var encodedIgnoringNil: MessagePackValue {
        var map = [MessagePackValue:MessagePackValue]()
        if let car = car {
            map[.string("car")] = car.encoded
        }
        if let carArray = carArray {
            map[.string("carArray")] = .array(carArray.map({ $0.encoded }))
        }
        if let carMap = carMap {
            var m = [MessagePackValue: MessagePackValue]()
            carMap.forEach({ m[.string($0)] = $1.encoded })
            map[.string("carMap")] = .map(m)
        }
        return .map(map)
    }
    
    static func generate(seed: UInt8) -> OptionalCarShop {
        return OptionalCarShop(
            car: OptionalCar.generate(seed: seed),
            carArray: [OptionalCar.generate(seed: seed + 1), OptionalCar.generate(seed: seed + 2)],
            carMap: ["a": OptionalCar.generate(seed: seed + 3), "b": OptionalCar.generate(seed: seed + 4)]
        )
    }
    
    static func empty() -> OptionalCarShop {
        return OptionalCarShop(car: nil, carArray: nil, carMap: nil)
    }
}
