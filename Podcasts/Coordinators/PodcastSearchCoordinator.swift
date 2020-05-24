//
//  SearchBarPodcastSearchControllerDelegate.swift
//  Podcasts
//
//  Created by Олег Черных on 13/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit

class PodcastSearchCoordinator: Coordinatable, PodcastsSearchControllerCoordinatorDelegate {
    var child: Coordinatable!
    var navigationController: UINavigationController!
    
    init(withNavigationController navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = PodcastsSearchController()
        viewController.coordinator = self
        viewController.navigationItem.title = "Podcasts"
        let model = PodcastsSearchModel(podcastService: ServiceLocator.podcastService)
        viewController.podcastsSearchModel = model
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func choose(podcast: Podcast) {
        let coordinator = EpisodesCoordintator(withNavigationController: navigationController)
        coordinator.start(withPodcast: podcast)
        child = coordinator
    }
}
