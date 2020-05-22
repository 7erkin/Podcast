//
//  AnyClosureObservable.swift
//  Podcasts
//
//  Created by Олег Черных on 19/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

class AnyClosureObservable<EventT>: ClosureObservable {
    typealias EmittedEvent = EventT
    let box: _AnyClosureObservable<EventT>
    let wrappedObject: AnyObject
    init<R: ClosureObservable>(_ wrappedObservable: R) where R.EmittedEvent == EmittedEvent {
        box = _AnyClosureObservableBox(wrappedObservable)
        wrappedObject = wrappedObservable
    }
    
    func subscribe(on serviceQueue: DispatchQueue, _ subscriber: @escaping (EventT) -> Void) -> Subscription {
        box.subscribe(on: serviceQueue, subscriber)
    }
}

class _AnyClosureObservable<T>: ClosureObservable {
    typealias EmittedEvent = T
    func subscribe(on serviceQueue: DispatchQueue, _ subscriber: @escaping (T) -> Void) -> Subscription {
        fatalError("Not implemented")
    }
}

class _AnyClosureObservableBox<B: ClosureObservable>: _AnyClosureObservable<B.EmittedEvent> {
    var box: B
    init(_ box: B) {
        self.box = box
    }
    
    override func subscribe(on serviceQueue: DispatchQueue, _ subscriber: @escaping (B.EmittedEvent) -> Void) -> Subscription {
        return box.subscribe(on: serviceQueue, subscriber)
    }
}
