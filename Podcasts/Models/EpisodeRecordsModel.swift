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
    private var subscribers: [UUID:(Event) -> Void] = [:]
    private let recordsManager: EpisodeRecordsManager
    init(recordsManager: EpisodeRecordsManager) {
        self.recordsManager = recordsManager
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
    
    func subscribe(_ subscriber: @escaping (Event) -> Void) -> Subscription {
        let key = UUID.init()
        subscribers[key] = subscriber
        return Subscription(canceller: { [unowned self] in self.subscribers.removeValue(forKey: key) })
    }
}
