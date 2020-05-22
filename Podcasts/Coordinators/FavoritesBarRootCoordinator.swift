//
//  FavoritesBarCoordinator.swift
//  Podcasts
//
//  Created by Олег Черных on 20/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit

class FavoritesBarRootCoordinator: RootCoordinator {
    override init() {
        super.init()
        navigationController.tabBarItem.image = UIImage(named: "favorites")!
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.tabBarItem.title = "Favorites"
    }
    
    func start() {
        let coordinator = FavoritesPodcastCoordinator(withNavigationController: navigationController)
        coordinator.start()
        child = coordinator
    }
}
