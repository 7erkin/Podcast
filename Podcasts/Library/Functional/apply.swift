//
//  apply.swift
//  Podcasts
//
//  Created by Олег Черных on 26/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

precedencegroup ApplyPrecendence {
    lowerThan: MultiplicationPrecedence
}

infix operator |: ApplyPrecendence

func | <X,Y>(lhs: (X) -> Y, rhs: X) -> Y {
    return lhs(rhs)
}

// ERRORS... WHY?
//func | <Y, ...Args> (lhs: (Args...) -> Y, rhs: (Args...)) -> Y {
//    return lhs(rhs)
//}
