//
//  ClosureObservable.swift
//  Podcasts
//
//  Created by Олег Черных on 19/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

class Subscription {
    private(set) var canceller: () -> Void
    init(canceller: @escaping () -> Void) { self.canceller = canceller }
    deinit { canceller() }
}

protocol ClosureObservable: class {
    associatedtype EmittedEvent
    func subscribe(on serviceQueue: DispatchQueue, _ subscriber: @escaping (EmittedEvent) -> Void) -> Subscription
}

// i want to provide default version of subscribe BUT I DON'T MAKE PUBLIC subscribers in protocol
//extension ClosureObservable {
//    func subscribe(_ subscriber: @escaping (EmittedEvent) -> Void) -> Subscription {
//        let key = UUID.init()
//        subscribers[key] = subscriber
//        return Subscription(canceller: { [weak self] in self?.subscribers.removeValue(forKey: key) })
//    }
//
//    func notifyAll(withEvent event: EmittedEvent) {
//        subscribers.values.forEach { $0(event) }
//    }
//}
