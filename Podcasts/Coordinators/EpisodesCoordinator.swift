//
//  SearchBarEpisodesControllerCoordinatorDelegate.swift
//  Podcasts
//
//  Created by Олег Черных on 13/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit

final class EpisodesCoordintator: Coordinatable {
    var child: Coordinatable!
    var navigationController: UINavigationController!
    
    init(withNavigationController navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start(withPodcast podcast: Podcast) {
        let episodesController = EpisodesController()
        let recordsManager = EpisodeRecordsManager.shared
        recordsManager.recordsStorage = ServiceLocator.episodeRecordStorage
        recordsManager.recordFetcher = ServiceLocator.episodeRecordFetcher
        let model = EpisodesModel(
            podcast: podcast,
            player: Player.shared,
            podcastService: ServiceLocator.podcastService,
            recordsManager: ServiceLocator.recordsManager,
            favoritePodcastsStorage: ServiceLocator.favoritePodcastStorage
        )
        episodesController.model = model
        navigationController.pushViewController(episodesController, animated: true)
    }
}
