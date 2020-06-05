//
//  AnyCache.swift
//  Podcasts
//
//  Created by Олег Черных on 02/06/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import PromiseKit

final class AnyCache<TKey: Hashable, TValue>: Caching {
    typealias Key = TKey
    typealias Value = TValue
    
    private let box: _AnyCache<TKey, TValue>
    init<T: Caching>(_ wrappedCache: T) where T.Key == TKey, T.Value == TValue {
        self.box = _AnyCacheBox(wrappedCache)
    }
    
    func get(_ key: TKey) -> Promise<TValue> {
        return box.get(key)
    }
    
    func has(_ key: TKey) -> Promise<Bool> {
        return box.has(key)
    }
    
    func insert(key: TKey, value: TValue) -> Promise<Void> {
        return box.insert(key: key, value: value)
    }
}

private class _AnyCache<TKey: Hashable, TValue>: Caching {
    typealias Key = TKey
    typealias Value = TValue
    
    func insert(key: _AnyCache<TKey, TValue>.Key, value: _AnyCache<TKey, TValue>.Value) -> Promise<Void> {
        fatalError("Not implemented")
    }
    
    func has(_ key: TKey) -> Promise<Bool> {
        fatalError("Not implemented")
    }
    
    func get(_ key: _AnyCache<TKey, TValue>.Key) -> Promise<TValue> {
        fatalError("Not implemented")
    }
}

private final class _AnyCacheBox<Box: Caching>: _AnyCache<Box.Key, Box.Value> {
    private var box: Box!
    init(_ box: Box) {
        self.box = box
    }
    
    override func insert(key: Box.Key, value: Box.Value) -> Promise<Void> {
        return box.insert(key: key, value: value)
    }
    
    override func get(_ key: Box.Key) -> Promise<Box.Value> {
        return box.get(key)
    }
    
    override func has(_ key: Box.Key) -> Promise<Bool> {
        return box.has(key)
    }
}
