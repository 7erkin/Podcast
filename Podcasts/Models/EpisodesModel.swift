//
//  EpisodesProvider.swift
//  Podcasts
//
//  Created by Олег Черных on 11/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

protocol EpisodeListPlayable: class {
    func play(episodeByIndex episodeIndex: Int, inEpisodeList episodes: [Episode], of podcast: Podcast)
    func subscribe(_ subscriber: @escaping (PlayerEvent) -> Void) -> Subscription
}

class EpisodesModel {
    enum Event {
        case episodePicked
        case episodesFetched
    }
    
    var subscriber: ((Event) -> Void)!
    private(set) var podcast: Podcast
    private(set) var episodes: [Episode] = []
    private(set) var pickedEpisodeIndex: Int!
    private let podcastService: PodcastServicing!
    private let player: EpisodeListPlayable
    private let playerSubscription: Subscription
    init(podcast: Podcast, player: EpisodeListPlayable, podcastService: PodcastServicing) {
        self.podcast = podcast
        self.podcastService = podcastService
        self.player = player
        self.playerSubscription = self.player.subscribe { event in
            switch event {
            case .playingEpisodeChanged(let playedEpisode):
                DispatchQueue.main.async { [weak self] in
                    self?.pickedEpisodeIndex = playedEpisode.index
                    self?.notifyAll(withEvent: .episodePicked)
                }
                break
            default:
                break
            }
        }
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
        player.play(episodeByIndex: index, inEpisodeList: episodes, of: podcast)
    }
    
    // MARK: - helpers
    private func notifyAll(withEvent event: Event) {
        subscriber(event)
    }
}
