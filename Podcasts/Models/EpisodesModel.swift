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
    
    var subscriber: ((Event) -> Void)!
    private(set) var podcast: Podcast
    private(set) var episodes: [Episode] = []
    private(set) var pickedEpisodeIndex: Int!
    private let podcastService: PodcastServicing!
    private let player: EpisodeListPlayable & Observable
    private var playerSubscription: Subscription!
    init(podcast: Podcast, player: EpisodeListPlayable & Observable, podcastService: PodcastServicing) {
        self.podcast = podcast
        self.podcastService = podcastService
        self.player = player
        _ = firstly {
                self.player.subscribe { appEvent in
                    switch appEvent as! EpisodeListPlayableEvent {
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
            }.done { self.playerSubscription = $0 }
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
