//
//  ServiceLocator.swift
//  Podcasts
//
//  Created by Олег Черных on 20/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

class ServiceLocator {
    static let podcastService: PodcastServicing = ITunesService.shared
    static let defferedPodcastService: PodcastServicing = DefferedPodcastService(timeout: 1.5, wrappedPodcastService: ServiceLocator.podcastService)
    static let imageCache = InMemoryImageCache(withFlushPolicy: LatestImageFlushPolicy(withCacheMemoryLimit: 75))
    static let imageFetcher: ImageFetching = {
        let imageFetcher = ImageFetcher()
        return ImageFetcherProxi(cache: ServiceLocator.imageCache, fetcher: imageFetcher)
    }()
    static let favoritePodcastStorage: FavoritePodcastsStoraging = UserDefaultsFavoritePodcastsStorage.shared
    static let episodeRecordStorage: EpisodeRecordsStoraging = SQLEpisodeRecordsStorage.shared
}
