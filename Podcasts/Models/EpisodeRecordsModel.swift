//
//  EpisodeRecords.swift
//  Podcasts
//
//  Created by Олег Черных on 21/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import PromiseKit

class EpisodeRecordsModel {
    enum Event {
        case startLoadingEpisodes
        case episodesLoaded
        case episodeDeleted
        case episodeDownloadingProgress(episode: Episode, progress: Float)
    }
    
    private(set) var episodes: [Episode] = []
    private let recordsManager: EpisodeRecordsManager
    private let player: EpisodeListPlayable & Observable
    private var playerSubscription: Subscription!
    var subscriber: ((Event) -> Void)!
    init(recordsManager: EpisodeRecordsManager, player: EpisodeListPlayable & Observable) {
        self.recordsManager = recordsManager
        self.player = player
        _ = player.subscribe { appEvent in
            guard let event = appEvent as? EpisodeListPlayableEvent else { return }
            
            DispatchQueue.main.async { [weak self] in

            }
        }.done { self.playerSubscription = $0 }
    }
    
    func loadEpisodes() {
        _ = firstly {
            self.recordsManager.getEpisodesInfo()
        }.done { episodes in
            self.episodes = episodes
        }
    }
    
    func delete(episode: Episode) {
        self.recordsManager.delete(episode: episode)
    }
    
    func playEpisode(episodeIndex index: Int) {
        player.play(episodeByIndex: index, inEpisodeList: episodes, of: Podcast())
    }
}
