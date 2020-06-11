//
//  EpisodesProvider.swift
//  Podcasts
//
//  Created by Олег Черных on 11/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import PromiseKit

final class EpisodesModel {
    enum Event {
        case initialized
        case podcastStatusUpdated
    }
    // MARK: - data for client
    private(set) var podcast: Podcast
    private(set) var episodes: [Episode] = []
    private(set) var isPodcastFavorite: Bool!
    // MARK: - dependencies
    private var podcastStorage: FavoritePodcastStoraging
    private var trackListPlayer: TrackListPlaying
    private var episodeFetcher: EpisodeFetching
    // MARK: - subscriptions
    private var favoritePodcastsStorageSubscription: Subscription!
    // MARK: -
    init(
        podcast: Podcast,
        podcastStorage: FavoritePodcastStoraging,
        episodeFetcher: EpisodeFetching,
        trackListPlayer: TrackListPlaying
    ) {
        self.podcast = podcast
        self.podcastStorage = podcastStorage
        self.episodeFetcher = episodeFetcher
        self.trackListPlayer = trackListPlayer
    }
    // MARK: - public api
    func initialize() {
    }
    // MARK: - helpers
    private func fetchEpisodes() -> Promise<[Episode]> {
        return Promise { resolver in
            if let feedUrl = self.podcast.feedUrl {
                episodeFetcher.fetchEpisodes(url: feedUrl) { [weak self] episodes in
                    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                        guard let self = self else { return }
                        
                        let episodes = episodes.applyPodcastImageIfNeeded(self.podcast)
                        resolver.fulfill(episodes)
                    }
                }
            } else {
                throw BreakPromiseChainError()
            }
        }
    }
}
