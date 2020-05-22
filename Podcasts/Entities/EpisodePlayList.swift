//
//  PlayList.swift
//  Podcasts
//
//  Created by user166334 on 5/22/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import PromiseKit

enum EpisodePlayListEvent: AppEvent {
    case playingEpisodeChanged
    case episodeListChanged
}

class EpisodePlayList {
    private let serviceQueue = DispatchQueue.main
    private var subscribers: [UUID:(EpisodePlayListEvent) -> Void] = [:]
    private let episodes: [Episode]
    private var playingEpisodeIndex: Int
    private let creatorId: UUID
    private let id: Any?
    init(episodes: [Episode], playingEpisodeIndex index: Int, playListCreatorId: UUID, playListId: Any?) {
        self.episodes = episodes
        self.playingEpisodeIndex = index
        self.creatorId = playListCreatorId
        self.id = playListId
    }
    
    deinit {
        serviceQueue.async { [weak self] in
            self?.notifyAll(withEvent: .playingEpisodeChanged)
        }
    }
    
    func nextEpisode() {
        serviceQueue.async { [weak self] in
            self?.playingEpisodeIndex += 1
            self?.notifyAll(withEvent: .playingEpisodeChanged)
        }
    }
    
    func previousEpisode() {
        serviceQueue.async { [weak self] in
            self?.playingEpisodeIndex -= 1
            self?.notifyAll(withEvent: .playingEpisodeChanged)
        }
    }
    
    func getPlayingEpisode() -> Promise<Episode> {
        return Promise { resolver in
            serviceQueue.async { [weak self] in
                guard let self = self else { return }
                
                resolver.resolve(.fulfilled(self.episodes[self.playingEpisodeIndex]))
            }
        }
    }
    
    func hasNextEpisode() -> Promise<Bool> {
        return Promise { resolver in
            serviceQueue.async { [weak self] in
                guard let self = self else { return }
                
                resolver.resolve(.fulfilled(self.playingEpisodeIndex + 1 != self.episodes.count))
            }
        }
    }
    
    func hasPreviousEpisode() -> Promise<Bool> {
        return Promise { resolver in
            serviceQueue.async { [weak self] in
                guard let self = self else { return }
                
                resolver.resolve(.fulfilled(self.playingEpisodeIndex != 0))
            }
        }
    }
    
    func subscribe(_ subscriber: @escaping (EpisodePlayListEvent) -> Void) -> Promise<Subscription> {
        return Promise { resolver in
            let key = UUID.init()
            serviceQueue.async { [weak self] in
                self?.subscribers[key] = subscriber
                let subscription = Subscription { [weak self] in self?.subscribers.removeValue(forKey: key) }
                resolver.resolve(.fulfilled(subscription))
            }
        }
    }
    
    fileprivate func notifyAll(withEvent event: EpisodePlayListEvent) {
        subscribers.values.forEach { $0(event) }
    }
}

