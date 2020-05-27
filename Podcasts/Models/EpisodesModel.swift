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
        case episodeDeleted
        case episodeDownloaded
        case episodeDownloadingProgressUpdated
        case podcastStatusUpdated
        case episodeStartDownloading
    }
    
    var subscriber: ((Event) -> Void)!
    // MARK: - data for client
    private(set) var podcast: Podcast
    private(set) var episodes: [Episode] = []
    private(set) var storedEpisodes: [Episode] = []
    private(set) var pickedEpisodeIndex: Int?
    private(set) var isPodcastFavorite: Bool!
    private(set) var downloadingEpisodes: OrderedDictionary<Episode, Double> {
        get { recordsManager.downloadingEpisodes }
        set {}
    }
    // MARK: - dependencies
    private let recordsManager: EpisodeRecordsManager
    private let podcastService: PodcastServicing
    private let player: Player
    private let favoritePodcastsStorage: FavoritePodcastsStoraging
    // MARK: - subscriptions
    private var recordsManagerSubscription: Subscription!
    private var playListSubscription: Subscription!
    private var favoritePodcastsStorageSubscription: Subscription!
    // MARK: -
    private let token: EpisodeModelToken
    init(
        podcast: Podcast,
        player: Player,
        podcastService: PodcastServicing,
        recordsManager: EpisodeRecordsManager,
        favoritePodcastsStorage: FavoritePodcastsStoraging
    ) {
        self.podcast = podcast
        self.podcastService = podcastService
        self.player = player
        self.recordsManager = recordsManager
        self.favoritePodcastsStorage = favoritePodcastsStorage
        self.token = EpisodeModelToken(podcast: podcast)

        subscribeToRecordsManager()
        subscribeToFavoritePodcastsStorage()
    }
    // MARK: - public api
    func initialize() {
        if let playList = player.currentPlayList() {
            if let playListToken = playList.creatorToken as? EpisodeModelToken, token == playListToken {
                pickedEpisodeIndex = playList.getPlayingEpisodeItem().indexInList
                subscribeToPlayList(playList)
            }
        }
        
        let fetchEpisodesPromise = fetchEpisodes()
        let isPodcastFavoritePromise = favoritePodcastsStorage.hasPodcast(podcast)
        let getStoredEpisodeListPromise = firstly {
            recordsManager.storedEpisodeList
        }.then(on: DispatchQueue.global(qos: .userInitiated), flags: nil) { items -> Promise<[Episode]> in
            let episodes = items
                .filter { $0.podcast == self.podcast }
                .map { $0.episode }
            return Promise { resolver in resolver.fulfill(episodes) }
        }
        when(fulfilled: fetchEpisodesPromise, isPodcastFavoritePromise, getStoredEpisodeListPromise).done { episodes, isFavorite, storedEpisodeList in
            self.episodes = episodes
            self.isPodcastFavorite = isFavorite
            self.storedEpisodes = storedEpisodeList
            self.notifyAll(withEvent: .initialized)
        }.catch { _ in }
    }
    
    func pickEpisode(episodeIndex index: Int) {
        if let currentPlayList = player.currentPlayList(), let creatorToken = currentPlayList.creatorToken as? EpisodeModelToken {
            if creatorToken == token {
                currentPlayList.pickEpisodeWithIndex(index)
                return
            }
        }
        
        let episodePlayList = EpisodePlayList(
            playList: episodes.enumerated().map { EpisodePlayListItem(indexInList: $0, episode: $1, podcast: podcast) },
            playingItemIndex: index,
            creatorToken: token
        )
        subscribeToPlayList(episodePlayList)
        player.applyPlayList(episodePlayList)
        pickedEpisodeIndex = index
        notifyAll(withEvent: .episodePicked)
    }
    
    func addPodcastToFavorites() {
        favoritePodcastsStorage.save(podcast: podcast)
    }
    
    func downloadEpisode(episodeIndex index: Int) {
        recordsManager.downloadEpisode(episodes[index], ofPodcast: podcast)
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
                self?.updateWithPlayList(withEvent: event)
            }
        }
    }
    
    private func subscribeToRecordsManager() {
        recordsManagerSubscription = recordsManager.subscribe { [weak self] event in
            guard let self = self else { return }
            
            switch event {
            case .episodeDownloaded:
                self.updateStoredEpisodeList(withEvent: .episodeDownloaded)
            case .episodeDownloadingProgress:
                self.notifyAll(withEvent: .episodeDownloadingProgressUpdated)
                break
            case .episodeDeleted:
                self.updateStoredEpisodeList(withEvent: .episodeDeleted)
            default:
                break
            }
        }
    }
    
    private func subscribeToFavoritePodcastsStorage() {
        favoritePodcastsStorage.subscribe { [weak self] event in
            DispatchQueue.main.async {
                self?.updateWithFavoritePodcastsStorage(withEvent: event)
            }
        }.done { subscription in
            self.favoritePodcastsStorageSubscription = subscription
        }.catch { _ in }
    }
    // MARK: - Update model functions
    private func updateWithPlayList(withEvent event: EpisodePlayListEvent) {
        switch event {
        case .playingEpisodeChanged:
            let episode = player.currentPlayList()!.getPlayingEpisodeItem().episode
            pickedEpisodeIndex = episodes.firstIndex(of: episode)!
            notifyAll(withEvent: .episodePicked)
        case .episodeListChanged:
            pickedEpisodeIndex = nil
            notifyAll(withEvent: .episodePicked)
        }
    }
    
    private func updateWithFavoritePodcastsStorage(withEvent event: FavoritePodcastStoragingEvent) {
        switch event {
        case .podcastSaved:
            isPodcastFavorite = true
            notifyAll(withEvent: .podcastStatusUpdated)
        case .podcastDeleted:
            isPodcastFavorite = false
            notifyAll(withEvent: .podcastStatusUpdated)
        }
    }
    
    fileprivate func updateStoredEpisodeList(withEvent event: EpisodesModel.Event) {
        firstly {
            recordsManager.storedEpisodeList
        }.done {
            self.storedEpisodes = $0.map { $0.episode }
            self.subscriber(event)
        }.catch { _ in }
    }
}
