//
//  FileSystemLFUCache.swift
//  Podcasts
//
//  Created by Олег Черных on 02/06/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import PromiseKit

final class FileSystemLFUCache<TKey: Hashable, TValue>: Caching {
    typealias Key = TKey
    typealias Value = TValue
    
    init(size: Int) {
        fatalError("Not implemented")
    }
    
    func get(_ key: TKey) -> Promise<TValue> {
        fatalError("Not implemented")
    }
    
    func has(_ key: TKey) -> Promise<Bool> {
        fatalError("Not implemented")
    }
    
    func insert(key: TKey, value: TValue) -> Promise<Void> {
        fatalError("Not implemented")
    }
}
