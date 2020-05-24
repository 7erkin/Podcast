//
//  EpisodeRecords.swift
//  Podcasts
//
//  Created by Олег Черных on 21/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import PromiseKit

struct EpisodeRecordsModelToken: EpisodePlayListCreatorToken {}

class EpisodeRecordsModel {
    enum Event {
        case initialized
        case episodeDeleted
        case episodePicked
    }
    
    private(set) var records: [StoredEpisodeRecordItem] = []
    private let player: EpisodeListPlayable
    private var playListSubscription: Subscription!
    var subscriber: ((Event) -> Void)!
    private let recordsManager: EpisodeRecordsManager
    private var recordsManagerSubscription: Subscription!
    init(recordsManager: EpisodeRecordsManager, player: EpisodeListPlayable) {
        self.player = player
        self.recordsManager = recordsManager
        if let playList = player.currentPlayList() {
            if let _ = playList.creatorToken as? EpisodeRecordsModelToken {
                subscribeToPlayList(playList)
            }
        }
        subscribeToRecordsManager()
    }
    
    func initialize() {
        firstly {
            recordsManager.storedEpisodes
        }.done {
            self.records = $0
        }.catch { _ in
            
        }
    }
    
    func delete(episode: Episode) {
        recordsManager.deleteEpisode(episode)
    }
    
    func playEpisode(episodeIndex index: Int) {
        let playList = records.map { record -> EpisodePlayListItem in
            var episode = record.episode
            episode.streamUrl = record.recordUrl
            return EpisodePlayListItem(episode: episode, podcast: record.podcast)
        }
        let episodePlayList = EpisodePlayList(
            playList: playList,
            playingItemIndex: index,
            creatorToken: EpisodeRecordsModelToken()
        )
        subscribeToPlayList(episodePlayList)
        player.applyPlayList(episodePlayList)
    }
    
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
            case .episodeSaved(_):
                break
            case .episodeSavingProgress(let episode, let progress):
                break
            case .episodeDeleted(_):
                self?.recordsManager.storedEpisodes.done { episodes in
                    self?.records = episodes
                    self?.subscriber(.episodeDeleted)
                }.catch { _ in }
                break
            }
        }
    }
    
    fileprivate func updateModelWithPlayList(withEvent event: EpisodePlayListEvent) {}
}
