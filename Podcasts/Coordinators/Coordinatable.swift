//
//  Coordinating.swift
//  Podcasts
//
//  Created by Олег Черных on 13/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//
import UIKit

// why many children?
protocol Coordinatable {
    var child: Coordinatable! { get set }
    var navigationController: UINavigationController! { get set }
}

//extension Coordinatable {
//    // 'self' used before 'self.init' call or assignment to 'self'
//    init(withNavigationController navigationController: UINavigationController) {
//        self.init()
//        self.navigationController = navigationController
//    }
//}
