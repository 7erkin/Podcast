//
//  Caching.swift
//  Podcasts
//
//  Created by Олег Черных on 02/06/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import PromiseKit

protocol Caching: class {
    associatedtype Key where Key: Hashable
    associatedtype Value
    func get(_ key: Key) -> Promise<Value>
    func has(_ key: Key) -> Promise<Bool>
    func insert(key: Key, value: Value) -> Promise<Void>
}
