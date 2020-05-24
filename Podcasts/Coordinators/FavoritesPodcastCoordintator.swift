//
//  FavoriteBarPodcastCoordintator.swift
//  Podcasts
//
//  Created by Олег Черных on 20/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit

class FavoritesPodcastCoordinator: Coordinatable, FavoritesPodcastControllerCoordinatorDelegate {
    var child: Coordinatable!
    var navigationController: UINavigationController!
    
    init(withNavigationController navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let layout = UICollectionViewFlowLayout()
        let viewController = FavoritesPodcastController(collectionViewLayout: layout)
        viewController.coordinator = self
        let model = FavoritePodcastsModel(favoritePodcastsStorage: ServiceLocator.favoritePodcastStorage)
        viewController.favoritePodcastsModel = model
        viewController.navigationItem.title = "Favorites"
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func choose(podcast: Podcast) {
        let coordinator = EpisodesCoordintator(withNavigationController: navigationController)
        coordinator.start(withPodcast: podcast)
        child = coordinator
    }
}
