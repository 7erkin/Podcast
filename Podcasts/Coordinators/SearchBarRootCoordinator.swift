//
//  SearchBarCoordinator.swift
//  Podcasts
//
//  Created by Олег Черных on 13/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit

class SearchBarRootCoordinator: RootCoordinator {
    override init() {
        super.init()
        navigationController = UINavigationController()
        navigationController.tabBarItem.image = UIImage(named: "search")!
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.tabBarItem.title = "Search"
    }
    
    func start() {
        let coordinator = PodcastSearchCoordinator(withNavigationController: navigationController)
        coordinator.start()
        child = coordinator
    }
}
