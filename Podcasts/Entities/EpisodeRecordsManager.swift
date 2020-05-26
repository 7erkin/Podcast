//
//  EpisodeRecordDownloader.swift
//  Podcasts
//
//  Created by Олег Черных on 23/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import PromiseKit

struct BreakPromiseChainError: Error {}

// must be called from the main thread
class EpisodeRecordsManager {
    enum Event {
        case episodeDownloaded
        case episodeDeleted
        case episodeDownloadingProgress
        case episodeStartDownloading
    }
    
    private(set) var downloadingEpisodes: OrderedDictionary<Episode, Double> = [:]
    // MARK: - dependencies
    var recordsStorage: EpisodeRecordsStoraging!
    var recordFetcher: EpisodeRecordFetching!
    // MARK: -
    private var subscribers: [UUID:(Event) -> Void] = [:]
    static let shared = EpisodeRecordsManager()
    private init() {}
    
    func isEpisodeSaved(_ episode: Episode) -> Promise<Bool> {
        return recordsStorage.hasEpisode(episode)
    }
    
    func downloadEpisode(_ episode: Episode, ofPodcast podcast: Podcast) {
        firstly { () -> Promise<Bool> in
            recordsStorage.hasEpisode(episode)
        }.then { hasEpisode -> Promise<Data> in
            if hasEpisode { return Promise(error: BreakPromiseChainError()) }
            var isStartDownloadingNotified = false
            return self.recordFetcher.fetch(episode: episode) { progress in
                DispatchQueue.main.async { [weak self] in
                    if !isStartDownloadingNotified {
                        isStartDownloadingNotified = true
                        self?.notifyAll(withEvent: .episodeStartDownloading)
                    }
                    self?.downloadingEpisodes[episode] = progress
                    self?.notifyAll(withEvent: .episodeDownloadingProgress)
                }
            }
        }.then { data -> Promise<Void> in
            self.recordsStorage.save(episode: episode, ofPodcast: podcast, withRecord: data)
        }.done {
            self.downloadingEpisodes.removeValue(forKey: episode)
            self.notifyAll(withEvent: .episodeDownloaded)
        }.catch { _ in }
    }
    
    func deleteEpisode(_ episode: Episode) {
        firstly {
            recordsStorage.delete(episode: episode)
        }.done {
            self.notifyAll(withEvent: .episodeDeleted)
        }.catch { _ in }
    }
    
    var storedEpisodeList: Promise<[StoredEpisodeItem]> {
        return recordsStorage.getStoredEpisodeRecordList()
    }
    
    func subscribe(_ subscriber: @escaping (Event) -> Void) -> Subscription {
        let key = UUID.init()
        subscribers[key] = subscriber
        return Subscription { [weak self] in
            self?.subscribers.removeValue(forKey: key)
        }
    }
    // MARK: - helpers
    fileprivate func notifyAll(withEvent event: Event) {
        subscribers.values.forEach { $0(event) }
    }
}
