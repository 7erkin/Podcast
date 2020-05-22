//
//  EpisodesProvider.swift
//  Podcasts
//
//  Created by Олег Черных on 11/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import PromiseKit

class EpisodesModel {
    enum Event {
        case episodePicked
        case episodesFetched
    }
    private static let playListCreatorId = UUID()
    var subscriber: ((Event) -> Void)!
    private(set) var podcast: Podcast
    private(set) var episodes: [Episode] = []
    private(set) var pickedEpisodeIndex: Int!
    private let podcastService: PodcastServicing!
    private let player: EpisodeListPlayable
    private var playListSubscription: Subscription!
    init(podcast: Podcast, player: EpisodeListPlayable, podcastService: PodcastServicing) {
        self.podcast = podcast
        self.podcastService = podcastService
        self.player = player
    }
    
    func fetchEpisodes() {
        if let feedUrl = self.podcast.feedUrl {
            podcastService.fetchEpisodes(url: feedUrl) { [weak self] (episodes) in
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    guard let self = self else { return }
                    
                    let episodes = episodes.applyPodcastImageIfNeeded(self.podcast)
                    DispatchQueue.main.async { [weak self] in
                        self?.episodes = episodes
                        self?.notifyAll(withEvent: .episodesFetched)
                    }
                }
            }
        }
    }
    
    func pickEpisode(episodeIndex index: Int) {
        let playList = EpisodePlayList(
            episodes: episodes,
            playingEpisodeIndex: index,
            playListCreatorId: EpisodesModel.playListCreatorId,
            playListId: podcast
        )
        _ = playList.subscribe { event in
            DispatchQueue.main.async { [weak self] in
                self?.updateModelWithPlayList(withEvent: event)
            }
        }.done { self.playListSubscription = $0 }
        player.applyPlayList(playList)
    }
    
    // MARK: - helpers
    private func notifyAll(withEvent event: Event) {
        subscriber(event)
    }
    
    private func updateModelWithPlayList(withEvent event: EpisodePlayListEvent) {
        
    }
}
