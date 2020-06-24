//
//  EpisodesProvider.swift
//  Podcasts
//
//  Created by Олег Черных on 11/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import PromiseKit

enum EpisodesModelEvent {
    case initial(Podcast, [Episode], Bool)
    case episodesFetched(Podcast, [Episode])
    case podcastStatusUpdated(Bool)
}

final class EpisodesModel {
    private var podcast: Podcast
    private var episodes: [Episode] = [] { didSet { subscribers.fire(.episodesFetched(podcast, self.episodes)) } }
    private var isPodcastFavorite: Bool = false { didSet { subscribers.fire(.podcastStatusUpdated(self.isPodcastFavorite)) } }
    // MARK: - dependencies
    private var podcastStorage: FavoritePodcastsStoraging
    private var trackListPlayer: TrackListPlaying
    private var episodeFetcher: EpisodeFetching
    // MARK: -
    private var subscriptions: [Subscription] = []
    private var subscribers = Subscribers<EpisodesModelEvent>()
    // MARK: -
    init(
        podcast: Podcast,
        podcastStorage: FavoritePodcastsStoraging,
        episodeFetcher: EpisodeFetching,
        trackListPlayer: TrackListPlaying
    ) {
        self.podcast = podcast
        self.podcastStorage = podcastStorage
        self.episodeFetcher = episodeFetcher
        self.trackListPlayer = trackListPlayer
        
        self.podcastStorage
            .subscribe { [weak self] in self?.updateWithFavoritePodcastsStorage($0) }
            .stored(in: &subscriptions)
        
        fetchEpisodes()
    }
    
    func subscribe(
        _ subscriber: @escaping (EpisodesModelEvent) -> Void
    ) -> Subscription {
        subscriber(.initial(podcast, episodes, isPodcastFavorite))
        return subscribers.subscribe(action: subscriber)
    }
    
    func savePodcastAsFavorite() {
        podcastStorage.saveAsFavorite(podcast: podcast)
    }
    
    func playEpisode(withIndex index: Int) {
//        let trackList = episodes.map { Track(episode: $0, podcast: podcast, url: $0.streamUrl) }
//        trackListPlayer.setTrackList(trackList, withPlayingTrackIndex: index)
    }
    // MARK: - helpers
    private func fetchEpisodes() {
        if let feedUrl = self.podcast.feedUrl {
            episodeFetcher.fetchEpisodes(url: feedUrl) { [weak self] episodes in
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    guard let self = self else { return }
                    
                    self.episodes = episodes.applyPodcastImageIfNeeded(self.podcast)
                }
            }
        }
    }
    
    private func updateWithFavoritePodcastsStorage(_ event: FavoritePodcastsStorageEvent) {
        switch event {
        case .initial(let podcasts):
            isPodcastFavorite = podcasts.contains(podcast)
        case .removed(let podcast, _):
            isPodcastFavorite = podcast == self.podcast
        case .saved(let podcast, _):
            isPodcastFavorite = podcast == self.podcast
        }
    }
}
