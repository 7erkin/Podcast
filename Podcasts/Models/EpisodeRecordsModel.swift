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
        case episodePicked
        case episodeDownloadingProgress(episode: Episode, progress: Float)
    }
    
    private static let playListCreatorId = UUID()
    private(set) var episodes: [Episode] = []
    private let recordsManager: EpisodeRecordsManager
    private let player: EpisodeListPlayable
    private var playListSubscription: Subscription!
    var subscriber: ((Event) -> Void)!
    init(recordsManager: EpisodeRecordsManager, player: EpisodeListPlayable) {
        self.recordsManager = recordsManager
        self.player = player
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
        let playList = EpisodePlayList(
            episodes: episodes,
            playingEpisodeIndex: index,
            playListCreatorId: EpisodeRecordsModel.playListCreatorId,
            playListId: nil
        )
        _ = playList.subscribe { event in
            DispatchQueue.main.async { [weak self] in
                self?.updateModelWithPlayList(withEvent: event)
            }
        }.done { self.playListSubscription = $0 }
        player.applyPlayList(playList)
    }
    
    fileprivate func updateModelWithPlayList(withEvent event: EpisodePlayListEvent) {}
}
