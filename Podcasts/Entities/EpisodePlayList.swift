//
//  PlayList.swift
//  Podcasts
//
//  Created by user166334 on 5/22/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import PromiseKit

enum EpisodePlayListEvent {
    case playingEpisodeChanged
    case episodeListChanged
}

protocol EpisodePlayListCreatorToken {}

struct EpisodePlayListItem {
    var indexInList: Int
    var episode: Episode
    var podcast: Podcast
}

final class EpisodePlayList {
    private var subscribers: [UUID:(EpisodePlayListEvent) -> Void] = [:]
    private let playList: [EpisodePlayListItem]
    private var playingItemIndex: Int
    let creatorToken: EpisodePlayListCreatorToken
    init(playList: [EpisodePlayListItem], playingItemIndex index: Int, creatorToken: EpisodePlayListCreatorToken) {
        self.playList = playList
        self.playingItemIndex = index
        self.creatorToken = creatorToken
    }
    
    deinit {
        notifyAll(withEvent: .episodeListChanged)
    }
    
    func pickEpisodeWithIndex(_ index: Int) {
        playingItemIndex = index
        notifyAll(withEvent: .playingEpisodeChanged)
    }
    
    func pickNextEpisode() {
        playingItemIndex += 1
        notifyAll(withEvent: .playingEpisodeChanged)
    }
    
    func pickPreviousEpisode() {
        playingItemIndex -= 1
        notifyAll(withEvent: .playingEpisodeChanged)
    }
    
    func getPlayingEpisodeItem() -> EpisodePlayListItem {
        return playList[playingItemIndex]
    }
    
    func hasNextEpisode() -> Bool {
        return self.playingItemIndex + 1 != self.playList.count
    }
    
    func hasPreviousEpisode() -> Bool {
        return playingItemIndex != 0
    }
    
    func subscribe(_ subscriber: @escaping (EpisodePlayListEvent) -> Void) -> Subscription {
        let key = UUID.init()
        subscribers[key] = subscriber
        return Subscription { [weak self] in self?.subscribers.removeValue(forKey: key) }
    }
    
    fileprivate func notifyAll(withEvent event: EpisodePlayListEvent) {
        subscribers.values.forEach { $0(event) }
    }
}

