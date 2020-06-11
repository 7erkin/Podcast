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
    static let favoritePodcastStorage: FavoritePodcastSaving & FavoritePodcastRemoving = UserDefaultsFavoritePodcastStorage.shared
    static let episodeRecordStorage: EpisodeRecordStoraging = FileSystemRecordsStorage.shared!
    static let episodeRecordRepository: EpisodeRecordDownloading & EpisodeRecordRemoving = EpisodeRecordsRepository.shared
}
