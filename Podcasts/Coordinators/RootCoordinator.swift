//
//  RootCoordinator.swift
//  Podcasts
//
//  Created by Олег Черных on 20/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit

class RootCoordinator: NSObject, Coordinatable {
    var child: Coordinatable!
    var navigationController: UINavigationController!
    override init() {
        super.init()
        navigationController = UINavigationController()
        navigationController.delegate = self
    }
}

extension RootCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == UINavigationController.Operation.pop {
            // remove last coordinator
            var coordinatable: Coordinatable! = child
            while coordinatable.child.child != nil {
                coordinatable = coordinatable.child
            }
            coordinatable.child = nil
        }
        return nil
    }
}
