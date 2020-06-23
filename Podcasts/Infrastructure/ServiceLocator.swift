//
//  ServiceLocator.swift
//  Podcasts
//
//  Created by Олег Черных on 20/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

final class ServiceLocator {
    static let podcastService: PodcastFetching & EpisodeFetching & EpisodeRecordFetching = ITunesService.shared
    static let recordStorage: EpisodeRecordStoraging = FileSystemRecordsStorage()!
    static let recordRepository: EpisodeRecordRepositoring = EpisodeRecordsRepository(
        recordStorage: ServiceLocator.recordStorage,
        recordFetcher: ServiceLocator.podcastService
    )
    static let favoritePodcastsStorage: FavoritePodcastsStoraging = UserDefaultsFavoritePodcastStorage()
}
