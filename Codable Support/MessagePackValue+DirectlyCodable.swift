//
//  MessagePackValue+DirectlyCodable.swift
//  MessagePack
//
//  Created by cherrywoods on 09.02.18.
//  Licensed under Unlicense, https://unlicense.org
//

import Foundation
import MetaSerialization

// extend MessagePackValue
// so one can encode such values
// alongside with other instances, e.g:

/*
 func encode(to encoder: Encoder) {
     ...
     let extensionValue = MessagePackValue.extension(100, data)
     let otherValue = Date()
     ...
     var container = encoder.unkeyedContainer()
     container.encode(extensionValue)
     container.encode(otherValue)
 }
 */

// with this both encoding/decoding methods,
// can be mixed arbitrarily.

// the MessagePackValues just get passed on

extension MessagePackValue: DirectlyCodable {  }
