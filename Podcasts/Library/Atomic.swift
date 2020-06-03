//
//  Atomic.swift
//  Podcasts
//
//  Created by Олег Черных on 03/06/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

final class Atomic<T> {
    private let queue = DispatchQueue(label: "Atomic\(UUID.init())")
    private var _value: T

    init(_ value: T) {
        self._value = value
    }

    var value: T {
        get { return queue.sync { self._value } }
    }

    func mutate(_ transform: (inout T) -> ()) {
        queue.sync { transform(&self._value) }
    }
}
