//
//  composition.swift
//  Podcasts
//
//  Created by user166334 on 5/26/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

// why should i write if it all depend on operator implementation
precedencegroup CompositionPrecendence {
    associativity: right
    higherThan: MultiplicationPrecedence
}

infix operator •: CompositionPrecendence

func • <T, U, V> (lhs: @escaping (V) -> T, rhs: @escaping (U) -> V) -> (U) -> T {
    return { lhs(rhs($0)) }
}

