//
//  EpisodeRecords.swift
//  Podcasts
//
//  Created by Олег Черных on 21/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import PromiseKit

struct DownloadedEpisodesModelToken: EpisodePlayListCreatorToken {}

class DownloadedEpisodesModel {
    enum Event {
        case initialized
        case episodeDeleted
        case episodePicked
        case episodeStartDownloading
        case episodeDownloaded
        case episodeDownloadingProgressUpdated
    }
    // MARK: - data for client
    private(set) var storedEpisodes: [Episode] = []
    private(set) var pickedEpisodeIndex: Int?
    private(set) var downloadingEpisodes: OrderedDictionary<Episode, Double> {
        get { recordsManager.downloadingEpisodes }
        set {}
    }
    // MARK: - subscriptions
    private var recordsManagerSubscription: Subscription!
    private var playListSubscription: Subscription!
    // MARK: -
    private let player: EpisodeListPlayable
    var subscriber: ((Event) -> Void)!
    private let recordsManager: EpisodeRecordsManager
    private weak var episodePlayList: EpisodePlayList?
    init(recordsManager: EpisodeRecordsManager, player: EpisodeListPlayable) {
        self.player = player
        self.recordsManager = recordsManager
        if let playList = player.currentPlayList() {
            if let _ = playList.creatorToken as? DownloadedEpisodesModelToken {
                subscribeToPlayList(playList)
            }
        }
        subscribeToRecordsManager()
    }
    // MARK: - public api
    func initialize() {
        firstly {
            recordsManager.storedEpisodeList
        }.done {
            self.storedEpisodes = $0.map { $0.episode }
            self.subscriber(.initialized)
        }.catch { _ in }
    }
    
    func delete(episode: Episode) {
        recordsManager.deleteEpisode(episode)
    }
    
    func pickEpisode(episodeIndex index: Int) {
        firstly {
            recordsManager.storedEpisodeList
        }.done {
            let playList = $0.enumerated().map { (index, item) -> EpisodePlayListItem in
                var episodeCopy = item.episode
                episodeCopy.streamUrl = item.recordUrl
                return EpisodePlayListItem(indexInList: index, episode: episodeCopy, podcast: item.podcast)
            }
            let episodePlayList = EpisodePlayList(
                playList: playList,
                playingItemIndex: index,
                creatorToken: DownloadedEpisodesModelToken()
            )
            self.episodePlayList = episodePlayList
            self.subscribeToPlayList(episodePlayList)
            self.player.applyPlayList(episodePlayList)
        }.catch { _ in }
    }
    // MARK: - subscribe functions
    private func subscribeToPlayList(_ playList: EpisodePlayList) {
        playListSubscription = playList.subscribe { event in
            DispatchQueue.main.async { [weak self] in
                self?.updateModelWithPlayList(withEvent: event)
            }
        }
    }
    
    private func subscribeToRecordsManager() {
        recordsManagerSubscription = recordsManager.subscribe { [weak self] event in
            DispatchQueue.main.async { [weak self] in
                self?.updateModelWithRecordsManager(withEvent: event)
            }
        }
    }
    // MARK: - update functions
    fileprivate func updateModelWithPlayList(withEvent event: EpisodePlayListEvent) {
        switch event {
        case .episodeListChanged:
            pickedEpisodeIndex = nil
            subscriber(.episodePicked)
        case .playingEpisodeChanged:
            if let playList = self.episodePlayList {
                pickedEpisodeIndex = playList.getPlayingEpisodeItem().indexInList
                subscriber(.episodePicked)
            }
        }
    }
    
    fileprivate func updateModelWithRecordsManager(withEvent event: EpisodeRecordsManager.Event) {
        switch event {
        case .episodeDownloadingProgress:
            subscriber(.episodeDownloadingProgressUpdated)
            break
        case .episodeDeleted:
            updateStoredEpisodeList(withEvent: .episodeDeleted)
        case .episodeDownloaded:
            updateStoredEpisodeList(withEvent: .episodeDownloaded)
        case .episodeStartDownloading:
            subscriber(.episodeStartDownloading)
        }
    }
    
    fileprivate func updateStoredEpisodeList(withEvent event: DownloadedEpisodesModel.Event) {
        firstly {
            recordsManager.storedEpisodeList
        }.done {
            self.storedEpisodes = $0.map { $0.episode }
            self.subscriber(event)
        }.catch { _ in }
    }
}
