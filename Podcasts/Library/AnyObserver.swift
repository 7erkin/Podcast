//
//  AnyObserver.swift
//  Podcasts
//
//  Created by Олег Черных on 11/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

class AnyObserver<T>: Hashable, Observer {
    typealias AcceptedEvent = T
    func notify(withEvent event: T) {
        box.notify(withEvent: event)
    }
    
    static func == (lhs: AnyObserver<T>, rhs: AnyObserver<T>) -> Bool {
        return true
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    private let id: UUID = .init()
    
    var box: _AnyObserverBox<T>
    
    init<WrappedObserver: Observer>(_ wrappedObserver: WrappedObserver) where T == WrappedObserver.AcceptedEvent  {
        box = _ObserverBox(wrappedObserver)
    }
}

class _AnyObserverBox<T>: Observer {
    typealias AcceptedEvent = T
    func notify(withEvent event: T) {
        fatalError("Abstract class")
    }
}

class _ObserverBox<Box: Observer>: _AnyObserverBox<Box.AcceptedEvent> {
    let box: Box
    
    init(_ box: Box) {
        self.box = box
    }
    
    override func notify(withEvent event: Box.AcceptedEvent) {
        box.notify(withEvent: event)
    }
}
