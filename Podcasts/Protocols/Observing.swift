//
//  Observing.swift
//  Podcasts
//
//  Created by user166334 on 6/5/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

protocol Observing: class {
    associatedtype Event
    var subscribers: [UUID:(Event) -> Void] { get set }
    func subscribe(_ subscriber: @escaping (Event) ->Void) -> Subscription
}

extension Observing {
    func subscribe(_ subscriber: @escaping (Event) -> Void) -> Subscription {
        let key = UUID()
        subscribers[key] = subscriber
        return Subscription { [weak self] in self?.subscribers.removeValue(forKey: key) }
    }
    
    func notifyAll(withEvent event: Event) {
        subscribers.values.forEach { $0(event) }
    }
}
