//
//  ObservedValue.swift
//  Podcasts
//
//  Created by Олег Черных on 02/06/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

class ObservedValue<T> {
    var value: T { didSet { valueChanged?(self.value) } }
    var valueChanged: ((T) -> Void)! { didSet { self.valueChanged(value) } }
    init(_ value: T) {
        self.value = value
    }
}
