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
    case playingTrackIndexUpdated(Int?)
}

final class EpisodesModel {
    private lazy var trackListIdentifier: String = { [unowned self] in self.podcast.name ?? "\(UUID())" }()
    private var podcast: Podcast
    private var episodes: [Episode] = [] { didSet { subscribers.fire(.episodesFetched(podcast, self.episodes)) } }
    private var isPodcastFavorite: Bool = false { didSet { subscribers.fire(.podcastStatusUpdated(self.isPodcastFavorite)) } }
    // MARK: - dependencies
    private var podcastStorage: FavoritePodcastsStoraging
    private var trackListPlayer: TrackListPlaying
    // MARK: -
    private var subscriptions: [Subscription] = []
    private var subscribers = Subscribers<EpisodesModelEvent>()
    private var currentPlayingTrackList: TrackList? {
        willSet {
            if trackListIdentifier == self.currentPlayingTrackList?.sourceIdentifier {
                if self.currentPlayingTrackList?.currentPlayingTrackIndex != newValue?.currentPlayingTrackIndex {
                    subscribers.fire(.playingTrackIndexUpdated(newValue?.currentPlayingTrackIndex))
                }
            }
        }
    }
    // MARK: -
    init(
        podcast: Podcast,
        podcastStorage: FavoritePodcastsStoraging,
        episodeFetcher: EpisodeFetching,
        trackListPlayer: TrackListPlaying
    ) {
        self.podcast = podcast
        self.podcastStorage = podcastStorage
        self.trackListPlayer = trackListPlayer
        
        self.podcastStorage
            .subscribe { [weak self] in self?.updateWithFavoritePodcastsStorage($0) }
            .stored(in: &subscriptions)
        
        self.trackListPlayer
            .subscribe { [weak self] in self?.updateWithTrackListPlayer($0) }
            .stored(in: &subscriptions)
        
        fetchEpisodes(withEpisodeFetcher: episodeFetcher)
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
        if let trackList = currentPlayingTrackList {
            if trackList.sourceIdentifier == trackListIdentifier {
                trackListPlayer.playTrack(atIndex: index)
                return
            }
        }
        
        let trackList = TrackList(
            trackListIdentifier,
            tracks: episodes.map { Track(episode: $0, podcast: podcast, url: $0.streamUrl) }, playingTrackIndex: index
        )
        trackListPlayer.setTrackList(trackList, reasonOfSetting: .setNewTrackList)
    }
    // MARK: - helpers
    private func fetchEpisodes(withEpisodeFetcher episodeFetcher: EpisodeFetching) {
        if let feedUrl = self.podcast.feedUrl {
            episodeFetcher.fetchEpisodes(url: feedUrl) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let episodes):
                    self.episodes = episodes.applyPodcastImageIfNeeded(self.podcast)
                case .failure(_):
                    break
                }
            }
        }
    }
    
    private func updateWithTrackListPlayer(_ event: TrackListPlayerEvent) {
        switch event {
        case .initial(let trackList):
            currentPlayingTrackList = trackList
        case .playingTrackUpdated(let trackList):
            currentPlayingTrackList = trackList
        case .trackListUpdated(let trackList):
            currentPlayingTrackList = trackList
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
