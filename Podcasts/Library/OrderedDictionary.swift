//
//  OrderedDictionary.swift
//  Podcasts
//
//  Created by user166334 on 5/26/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

public struct OrderedDictionary<Key: Hashable, Value> {
    public typealias Element = (key: Key, value: Value)

    fileprivate var array: [Key]
    fileprivate var dict: [Key: Value]
    public init() {
        self.array = []
        self.dict = [:]
    }

    public subscript(key: Key) -> Value? {
        get {
            return dict[key]
        }
        set {
            if let newValue = newValue {
                updateValue(newValue, forKey: key)
            } else {
                removeValue(forKey: key)
            }
        }
    }
    
    @discardableResult
    public mutating func updateValue(_ value: Value, forKey key: Key) -> Value? {
        if let oldValue = dict[key] {
            dict[key] = value
            return oldValue
        }

        dict[key] = value
        array.append(key)
        return nil
    }
    
    @discardableResult
    public mutating func removeValue(forKey key: Key) -> Value? {
        guard let value = dict[key] else {
            return nil
        }
        dict[key] = nil
        array.remove(at: array.firstIndex(of: key)!)
        return value
    }

    public var values: [Value] {
        return self.array.map { self.dict[$0]! }
    }

    public mutating func removeAll() {
        self.array.removeAll()
        self.dict.removeAll()
    }
}

extension OrderedDictionary: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init()
        for element in elements {
            updateValue(element.1, forKey: element.0)
        }
    }
}

extension OrderedDictionary: CustomStringConvertible {
    public var description: String {
        var string = "["
        for (idx, key) in array.enumerated() {
            string += "\(key): \(dict[key]!)"
            if idx != array.count - 1 {
                string += ", "
            }
        }
        string += "]"
        return string
    }
}

extension OrderedDictionary: RandomAccessCollection {
    public var startIndex: Int { return array.startIndex }
    public var endIndex: Int { return array.endIndex }
    public subscript(index: Int) -> Element {
        let key = array[index]
        let value = dict[key]!
        return (key, value)
    }
}
