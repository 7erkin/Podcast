//
//  Subscribers.swift
//  Podcasts
//
//  Created by Олег Черных on 11/06/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

final class Subscribers<T> {
    private var subscriberActions: [UUID: (T) -> Void] = [:]

    func subscribe(action: @escaping (T) -> Void) -> Subscription {
        let uuid = UUID()
        subscriberActions[uuid] = action

        return Subscription { [weak self] in
            self?.subscriberActions[uuid] = nil
        }
    }

    func fire(_ value: T) {
        subscriberActions.values.forEach { $0(value) }
    }
}
