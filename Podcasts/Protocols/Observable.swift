//
//  Observable.swift
//  Podcasts
//
//  Created by Олег Черных on 11/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import PromiseKit

class Subscription {
    typealias SubscriptionCanceller = () -> Void
    private let canceller: SubscriptionCanceller
    init(_ canceller: @escaping SubscriptionCanceller) { self.canceller = canceller }
    deinit {
        canceller()
    }
}

protocol AppEvent {}

protocol Observable {
    func subscribe(_ subscriber: @escaping (AppEvent) -> Void) -> Promise<Subscription>
}
