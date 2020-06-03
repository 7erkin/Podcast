//
//  ServiceLocator.swift
//  Podcasts
//
//  Created by Олег Черных on 20/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

final class ServiceLocator {
    static let podcastService: PodcastServicing = ITunesService.shared
    static let defferedPodcastService: PodcastServicing = DefferedPodcastService(timeout: 1.5, wrappedPodcastService: ServiceLocator.podcastService)
    static let favoritePodcastStorage: FavoritePodcastsStoraging = UserDefaultsFavoritePodcastsStorage.shared
    static let episodeRecordStorage: EpisodeRecordsStoraging = FileSystemRecordsStorage.shared!
    static let recordsManager: EpisodeRecordsManager = {
        var recordsManager = EpisodeRecordsManager.shared
        recordsManager.recordsStorage = ServiceLocator.episodeRecordStorage
        return recordsManager
    }()
}
