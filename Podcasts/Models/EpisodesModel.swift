//
//  EpisodesProvider.swift
//  Podcasts
//
//  Created by Олег Черных on 11/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import PromiseKit
import Combine

enum EpisodesModelEvent {
    case initial(EpisodesModel.State)
    case episodesFetched(EpisodesModel.State)
    case podcastStatusUpdated(EpisodesModel.State)
    case playingTrackIndexUpdated(EpisodesModel.State)
    case networkReachabilityChanged(EpisodesModel.State)
}

final class EpisodesModel {
    struct State {
        var emit: ((EpisodesModelEvent) -> Void)?
        var podcast: Podcast
        var episodes: [Episode] = []
        var isEpisodesFetching: Bool = false {
            willSet {
                if self.isEpisodesFetching == newValue { return }
                if self.isEpisodesFetching {
                    emit?(.episodesFetched(self))
                }
            }
            didSet {
                emit?(.episodesFetched(self))
            }
        }
        var isPodcastFavorite: Bool? {
            didSet {
                emit?(.podcastStatusUpdated(self))
            }
        }
        var isNetworkReachable: Bool? {
            didSet {
                emit?(.networkReachabilityChanged(self))
            }
        }
        var playingTrackIndex: Int? {
            didSet {
                emit?(.playingTrackIndexUpdated(self))
            }
        }
    }
    private var state: State
    private lazy var trackListSourceIdentifier: String = { [unowned self] in self.state.podcast.name ?? "\(UUID())" }()
    // MARK: - dependencies
    private var podcastStorage: FavoritePodcastsStoraging
    private var trackListPlayer: TrackListPlaying
    // MARK: -
    private var combineSubscriptions: Set<AnyCancellable> = []
    private var subscriptions: [Subscription] = []
    private var subscribers = Subscribers<EpisodesModelEvent>()
    private var currentPlayingTrackList: TrackList? {
        willSet {
//            if trackListIdentifier == self.currentPlayingTrackList?.sourceIdentifier {
//                if self.currentPlayingTrackList?.currentPlayingTrackIndex != newValue?.currentPlayingTrackIndex {
//                    subscribers.fire(.playingTrackIndexUpdated(newValue?.currentPlayingTrackIndex))
//                }
//            }
        }
    }
    // MARK: -
    init(
        podcast: Podcast,
        podcastStorage: FavoritePodcastsStoraging,
        episodeFetcher: EpisodeFetching,
        trackListPlayer: TrackListPlaying
    ) {
        self.podcastStorage = podcastStorage
        self.trackListPlayer = trackListPlayer
        state = .init(podcast: podcast)
        state.emit = { [weak self] in self?.emit(event: $0) }
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
        subscriber(.initial(state))
        return subscribers.subscribe(action: subscriber)
    }
    
    func savePodcastAsFavorite() {
        podcastStorage.saveAsFavorite(podcast: state.podcast)
    }
    
    func playEpisode(withIndex index: Int) {
        if let trackList = currentPlayingTrackList {
            if trackList.sourceIdentifier == trackListSourceIdentifier {
                trackListPlayer.playTrack(atIndex: index)
                return
            }
        }
        
        let trackList = TrackList(
            trackListSourceIdentifier,
            tracks: state.episodes.map { Track(episode: $0, podcast: state.podcast, url: $0.streamUrl) },
            playingTrackIndex: index
        )
        trackListPlayer.setTrackList(trackList, reasonOfSetting: .setNewTrackList)
    }
    // MARK: - helpers
    private func fetchEpisodes(withEpisodeFetcher episodeFetcher: EpisodeFetching) {
        if let feedUrl = self.state.podcast.feedUrl {
            episodeFetcher.fetchEpisodes(url: feedUrl) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let episodes):
                    self.state.episodes = episodes.applyPodcastImageIfNeeded(self.state.podcast)
                    self.state.isEpisodesFetching = false
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
            state.isPodcastFavorite = podcasts.contains(state.podcast)
        case .removed(let podcast, _):
            state.isPodcastFavorite = podcast == self.state.podcast
        case .saved(let podcast, _):
            state.isPodcastFavorite = podcast == self.state.podcast
        }
    }
    
    private func emit(event: EpisodesModelEvent) {
        subscribers.fire(event)
    }
}
