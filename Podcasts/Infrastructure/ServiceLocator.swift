//
//  ServiceLocator.swift
//  Podcasts
//
//  Created by Олег Черных on 20/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
// это плохо, я знаю
final class ServiceLocator {
    static let podcastService: PodcastFetching & EpisodeFetching = ITunesService.shared
    static let episodeRecordDownloader: EpisodeRecordDownloading = EpisodeRecordDownloader(
        sessionScheduler: ServiceLocator.sessionScheduler
    )
    static let recordStorage: EpisodeRecordStoraging = FileSystemRecordsStorage()!
    static let recordRepository: EpisodeRecordRepositoring = EpisodeRecordRepository(
        recordStorage: ServiceLocator.recordStorage,
        recordDownloader: ServiceLocator.episodeRecordDownloader
    )
    static let favoritePodcastsStorage: FavoritePodcastsStoraging = UserDefaultsFavoritePodcastStorage()
    static let sessionScheduler = SessionScheduler()
    static let networkReachability = NetworkReachability()
    static let urlSessionLogger: URLSessionLogger? = nil
}
