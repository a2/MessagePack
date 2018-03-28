//
//  Models.swift
//  MessagePackTests
//
//  Created by Andrew Eng on 21/2/18.
//

import Foundation
@testable import MessagePack

struct Car: Model {
    let id: Data
    let brand: String
    let power: Double
    
    static func ==(lhs: Car, rhs: Car) -> Bool {
        return lhs.id == rhs.id && lhs.brand == rhs.brand && lhs.power == rhs.power
    }
    
    var encoded: MessagePackValue {
        return .map([
            .string("id"): .binary(id),
            .string("brand"): .string(brand),
            .string("power"): .double(power)
            ])
    }
    
    static func generate(seed: UInt8) -> Car {
        return Car(id: Data(bytes: [seed, seed + 1]), brand: "\(seed)", power: (3.14 * Double(seed)))
    }
}

struct CarShop: Model {
    let car: Car
    let carArray: [Car]
    let carMap: [String: Car]
    
    static func ==(lhs: CarShop, rhs: CarShop) -> Bool {
        return lhs.car == rhs.car && lhs.carArray == rhs.carArray && lhs.carMap == rhs.carMap
    }
    
    var encoded: MessagePackValue {
        var map = [MessagePackValue: MessagePackValue]()
        carMap.forEach({ map[.string($0)] = $1.encoded })
        return .map([
            .string("car"): car.encoded,
            .string("carArray"): .array(carArray.map({ $0.encoded })),
            .string("carMap"): .map(map)
            ])
    }
    
    static func generate(seed: UInt8) -> CarShop {
        return CarShop(
            car: Car.generate(seed: seed),
            carArray: [Car.generate(seed: seed + 1), Car.generate(seed: seed + 2)],
            carMap: ["a": Car.generate(seed: seed + 3), "b": Car.generate(seed: seed + 4)]
        )
    }
}
