//
//  Subscription.swift
//  Podcasts
//
//  Created by Олег Черных on 31/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

final class Subscription {
    typealias SubscriptionCanceller = () -> Void
    private let canceller: SubscriptionCanceller
    init(_ canceller: @escaping SubscriptionCanceller) { self.canceller = canceller }
    deinit {
        canceller()
    }
}

extension Subscription {
    func stored(in subscriptions: inout [Subscription]) {
        subscriptions.append(self)
    }
}
