//
//  WeakReference.swift
//  Podcasts
//
//  Created by Олег Черных on 11/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

// used in Set as a type of instance
// expected that Set<WeakReference<T>> will be used only in main thread
class WeakReference<T: AnyObject>: Hashable where T: Hashable {
    static func == (lhs: WeakReference<T>, rhs: WeakReference<T>) -> Bool {
//        if let lhsBox = lhs.box, let rhsBox = rhs.box {
//            return lhsBox.hashValue == rhsBox.hashValue
//        }
        return false
    }
    
    let id: UUID = .init()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
     var box: T
    
    init(_ box: T) {
        self.box = box
    }
}

// such struct covered only my demand and must be replace after
struct WeakSet<T: AnyObject>: ExpressibleByArrayLiteral where T: Hashable {
    typealias ArrayLiteralElement = T
    typealias WrappedSetElement = WeakReference<T>
    typealias WrappedSet = Set<WrappedSetElement>
    
    init(arrayLiteral elements: T...) {
        elements.forEach { set.insert(WeakReference($0)) }
    }
    
    private var set: WrappedSet = []
    
    mutating func remove(at index: WrappedSet.Index) -> T {
        // Overlapping accesses to 'self', but modification requires exclusive access; consider copying to a local variable
        // _invoke(set.remove(at: index)) ??????? *overlapping accesses to self error*
        // https://docs.swift.org/swift-book/LanguageGuide/MemorySafety.html
        return set.remove(at: index).box
    }
    
    @discardableResult
    mutating func remove(_ member: T) -> T? {
        if let index = set.firstIndex(where: { $0.box == member }) {
            return set.remove(at: index).box
        }
        return Optional.none
    }
    
    @discardableResult
    mutating func insert(_ element: T) -> (inserted: Bool, memberAfterInsert: WrappedSetElement) {
        return set.insert(WrappedSetElement(element))
    }
    
    mutating func forEach(_ body: (T) -> Void) {
        defer {
            clearEmptyReferences()
        }
        set.forEach {
            //if let box = $0.box {
            body($0.box)
            //}
        }
    }
    
    private mutating func clearEmptyReferences() {
        set
            .filter { $0.box == Optional.none }
            .forEach { set.remove($0) }
    }
    
//    private func _invoke<S>(_ invokable: @autoclosure () -> S) -> S {
//        defer {
//
//        }
//        return invokable()
//    }
}
