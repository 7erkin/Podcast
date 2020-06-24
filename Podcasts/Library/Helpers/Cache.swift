//
//  Cache.swift
//  Podcasts
//
//  Created by Олег Черных on 24/06/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

final class Cache<Key: Hashable, Value> {
    private let wrapped = NSCache<WrappedKey, Entry>()
    func insert(_ key: Key, _ value: Value) {
        wrapped.setObject(Entry(value), forKey: WrappedKey(key))
    }
    
    func value(forKey key: Key) -> Value? {
        return wrapped.object(forKey: WrappedKey(key))?.value
    }
    
    func removeValue(forKey key: Key) {
        wrapped.removeObject(forKey: WrappedKey(key))
    }
}

private extension Cache {
    final class WrappedKey: NSObject {
        let key: Key
        init(_ key: Key) { self.key = key }
        
        override var hash: Int { return key.hashValue }
        
        override func isEqual(_ object: Any?) -> Bool {
            guard let wrappedKey = object as? WrappedKey else { return false }
            
            return wrappedKey.key == key
        }
    }
    
    final class Entry {
        let value: Value
        init(_ value: Value) {
            self.value = value
        }
    }
}

extension Cache {
    subscript(key: Key) -> Value? {
        get {
            return wrapped.object(forKey: WrappedKey(key))?.value
        }
        set {
            guard let value = newValue else {
                removeValue(forKey: key)
                return
            }
            
            insert(key, value)
        }
    }
}
