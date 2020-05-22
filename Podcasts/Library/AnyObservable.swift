//
//  AnyObservable.swift
//  Podcasts
//
//  Created by Олег Черных on 11/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

class AnyObservable<T>: Hashable, Observable {
    typealias EmittedEvent = T
    typealias Subscriber = AnyObserver<T>
    
    static func == (lhs: AnyObservable<T>, rhs: AnyObservable<T>) -> Bool {
        return true
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    private let id: UUID = .init()
    
    var box: _AnyObservableBox<T>
    
    init<WrappedObservable: Observable>(_ wrappedObservable: WrappedObservable) where Subscriber == WrappedObservable.Subscriber  {
        box = _ObservableBox(wrappedObservable)
    }
    
    func subscribe(subscriber: Subscriber) {}
    func unsubscribe(subscriber: Subscriber) {}
}

class _AnyObservableBox<T>: Observable {
    typealias EmittedEvent = T
    typealias Subscriber = AnyObserver<T>
    
    func subscribe(subscriber: Subscriber) {
        fatalError("Not implemented")
    }
    
    func unsubscribe(subscriber: Subscriber) {
        fatalError("Not implemented")
    }
}

class _ObservableBox<Box: Observable>: _AnyObservableBox<Box.EmittedEvent> where Box.Subscriber == _AnyObservableBox<Box.EmittedEvent>.Subscriber {
    let box: Box
    
    init(_ box: Box) {
        self.box = box
    }
    
    override func subscribe(subscriber: Subscriber) {
        box.subscribe(subscriber: subscriber)
    }
    
    override func unsubscribe(subscriber: Subscriber) {
        box.unsubscribe(subscriber: subscriber)
    }
}
