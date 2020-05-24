//
//  EpisodesProvider.swift
//  Podcasts
//
//  Created by Олег Черных on 11/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import PromiseKit

struct EpisodeModelToken: EpisodePlayListCreatorToken {
    var podcast: Podcast
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.podcast == rhs.podcast
    }
}

class EpisodesModel {
    enum Event {
        case initialized
        case episodePicked
        case episodeSaved
        case episodeSavingProgressUpdated
        case podcastStatusUpdated
    }
    
    var subscriber: ((Event) -> Void)!
    private(set) var podcast: Podcast
    private(set) var episodes: [Episode] = []
    private(set) var savedEpisodes: Set<Episode> = []
    private(set) var pickedEpisodeIndex: Int?
    private(set) var isPodcastFavorite: Bool!
    private(set) var savingEpisodes: [Episode:Double] = [:]
    // MARK: - dependencies
    private let recordsManager: EpisodeRecordsManager
    private let podcastService: PodcastServicing!
    private let player: EpisodeListPlayable
    private let favoritePodcastsStorage: FavoritePodcastsStoraging
    // MARK: - subscriptions
    private var recordsManagerSubscription: Subscription!
    private var playListSubscription: Subscription!
    private var favoritePodcastsStorageSubscription: Subscription!
    // MARK: -
    private let token: EpisodeModelToken
    private weak var episodePlayList: EpisodePlayList!
    init(podcast: Podcast, player: EpisodeListPlayable, podcastService: PodcastServicing, recordsManager: EpisodeRecordsManager, favoritePodcastsStorage: FavoritePodcastsStoraging) {
        self.podcast = podcast
        self.podcastService = podcastService
        self.player = player
        self.recordsManager = recordsManager
        self.favoritePodcastsStorage = favoritePodcastsStorage
        self.token = EpisodeModelToken(podcast: podcast)
        if let playList = player.currentPlayList() {
            if let playListToken = playList.creatorToken as? EpisodeModelToken, token == playListToken {
                subscribeToPlayList(playList)
            }
        }
        subscribeToRecordsManager()
        subscribeToFavoritePodcastsStorage()
    }
    // MARK: - public api
    func initialize() {
        let fetchEpisodesPromise = fetchEpisodes()
        let isPodcastFavoritePromise = favoritePodcastsStorage.hasPodcast(podcast)
        let getSavedEpisodesPromise = firstly {
            recordsManager.storedEpisodes
        }.then(on: DispatchQueue.global(qos: .userInitiated), flags: nil) { items -> Promise<Set<Episode>> in
            let episodes = items
                .filter { $0.podcast == self.podcast }
                .reduce(into: Set<Episode>()) { $0.insert($1.episode) }
            return Promise { resolver in resolver.fulfill(episodes) }
        }
        when(fulfilled: fetchEpisodesPromise, isPodcastFavoritePromise, getSavedEpisodesPromise).done { episodes, isFavorite, savedEpisodes in
            self.episodes = episodes
            self.isPodcastFavorite = isFavorite
            self.savedEpisodes = savedEpisodes
            self.notifyAll(withEvent: .initialized)
        }.catch { _ in
        
        }
    }
    
    func pickEpisode(episodeIndex index: Int) {
        let episodePlayList = EpisodePlayList(
            playList: episodes.map { EpisodePlayListItem(episode: $0, podcast: podcast) },
            playingItemIndex: index,
            creatorToken: token
        )
        subscribeToPlayList(episodePlayList)
        player.applyPlayList(episodePlayList)
    }
    
    func addPodcastToFavorites() {
        favoritePodcastsStorage.save(podcast: podcast)
    }
    
    func saveEpisodeRecord(episodeIndex index: Int) {
        recordsManager.saveEpisode(episodes[index], ofPodcast: podcast)
    }
    // MARK: - helpers
    private func fetchEpisodes() -> Promise<[Episode]> {
        return Promise { resolver in
            if let feedUrl = self.podcast.feedUrl {
                podcastService.fetchEpisodes(url: feedUrl) { [weak self] episodes in
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
    
    private func notifyAll(withEvent event: Event) {
        subscriber(event)
    }
    // MARK: - Subscribe model functions
    private func subscribeToPlayList(_ playList: EpisodePlayList) {
        playListSubscription = playList.subscribe { event in
            DispatchQueue.main.async { [weak self] in
                self?.updateModelWithPlayList(withEvent: event)
            }
        }
    }
    
    private func subscribeToRecordsManager() {
        recordsManagerSubscription = recordsManager.subscribe { [weak self] event in
            switch event {
            case .episodeSaved(let episode):
                self?.savingEpisodes.removeValue(forKey: episode)
                self?.notifyAll(withEvent: .episodeSaved)
                break
            case .episodeSavingProgress(let episode, let progress):
                self?.savingEpisodes[episode] = progress
                self?.notifyAll(withEvent: .episodeSavingProgressUpdated)
                break
            default:
                break
            }
        }
    }
    
    private func subscribeToFavoritePodcastsStorage() {
        favoritePodcastsStorage.subscribe { [weak self] event in
            DispatchQueue.main.async {
                self?.updateModelWithFavoritePodcastsStorage(withEvent: event)
            }
        }.done { subscription in
            self.favoritePodcastsStorageSubscription = subscription
        }.catch { _ in }
    }
    // MARK: - Update model functions
    private func updateModelWithPlayList(withEvent event: EpisodePlayListEvent) {
        switch event {
        case .playingEpisodeChanged:
            let episode = episodePlayList.getPlayingEpisode().episode
            pickedEpisodeIndex = episodes.firstIndex(of: episode)!
            notifyAll(withEvent: .episodePicked)
        case .episodeListChanged:
            pickedEpisodeIndex = nil
            notifyAll(withEvent: .episodePicked)
        }
    }
    
    private func updateModelWithFavoritePodcastsStorage(withEvent event: FavoritePodcastStoragingEvent) {
        switch event {
        case .podcastSaved:
            isPodcastFavorite = true
            notifyAll(withEvent: .podcastStatusUpdated)
        case .podcastDeleted:
            isPodcastFavorite = false
            notifyAll(withEvent: .podcastStatusUpdated)
        }
    }
}
