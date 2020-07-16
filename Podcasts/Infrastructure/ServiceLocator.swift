//
//  ServiceLocator.swift
//  Podcasts
//
//  Created by Олег Черных on 20/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

final class ServiceLocator {
    static let podcastService: PodcastFetching & EpisodeFetching = ITunesService.shared
    static let episodeRecordDownloader: EpisodeRecordDownloading = RecordDownloader(
        urlSessionScheduler: ServiceLocator.backgroundSessionScheduler
    )
    static let recordStorage: EpisodeRecordStoraging = FileSystemRecordsStorage()!
    static let recordRepository: EpisodeRecordRepositoring = EpisodeRecordRepository(
        recordStorage: ServiceLocator.recordStorage,
        recordFetcher: ServiceLocator.episodeRecordDownloader
    )
    static let favoritePodcastsStorage: FavoritePodcastsStoraging = UserDefaultsFavoritePodcastStorage()
    static let backgroundSessionScheduler = URLSessionScheduler()
}
