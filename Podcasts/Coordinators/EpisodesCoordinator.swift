//
//  SearchBarEpisodesControllerCoordinatorDelegate.swift
//  Podcasts
//
//  Created by Олег Черных on 13/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit

class EpisodesCoordintator: Coordinatable, EpisodesControllerCoordinatorDelegate {
    var child: Coordinatable!
    var navigationController: UINavigationController!
    
    init(withNavigationController navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start(withPodcast podcast: Podcast) {
        let episodesController = EpisodesController()
        let repository = EpisodeRepository(withPodcast: podcast)
        episodeRepository = repository
        episodesController.coordinator = self
        episodesController.episodeRepository = repository
        episodesController.favoritePodcastRepository = ServiceLocator.favoritePodcastRepository
        navigationController.pushViewController(episodesController, animated: true)
    }
    
    func choose(episode: Episode) {
        if let playerEpisodeRepository = PlayerManager.shared.episodeRepository, playerEpisodeRepository === episodeRepository { return }
        
        PlayerManager.shared.episodeRepository = episodeRepository
    }
}
