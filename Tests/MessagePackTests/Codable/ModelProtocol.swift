//
//  ModelProtocol.swift
//  MessagePackTests
//
//  Created by Andrew Eng on 23/2/18.
//

import Foundation
@testable import MessagePack

protocol Model: Codable, Equatable {
    var encoded: MessagePackValue { get }
}

protocol OptionalModel: Model {
    var encodedIgnoringNil: MessagePackValue { get }
}
