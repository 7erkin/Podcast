//
//  EpisodeRecordsManager.swift
//  Podcasts
//
//  Created by Олег Черных on 22/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import PromiseKit

class EpisodeRecordsManager {
    enum Event {
        case episodeDownloadingProgress(episode: Episode, progress: Float)
        case episodeDeleted
        case episodeSaved
    }
    
    private var subscribers: [UUID:(Event) -> Void] = [:]
    private let storage: EpisodeRecordsStoraging
    private let recordFetcher: EpisodeRecordFetching
    // how to constraint serviceQueue to serial queue? Smth as constraint or assert
    init(storage: EpisodeRecordsStoraging, recordFetcher: EpisodeRecordFetching) {
        self.storage = storage
        self.recordFetcher = recordFetcher
    }
    
    func save(episode: Episode) {
        _ = Promise.value.then {
            self.recordFetcher.fetch(episode: episode) { progress in
                DispatchQueue.main.async { [weak self] in
                    self?.notifyAll(withEvent: .episodeDownloadingProgress(episode: episode, progress: progress))
                }
            }
        }.then { data in
            self.storage.save(episode: episode, withRecord: data)
        }.done {
            self.notifyAll(withEvent: .episodeSaved)
        }
    }
    
    func delete(episode: Episode) {
        _ = Promise.value.done {
            self.storage.delete(episode: episode)
        }.done {
            self.notifyAll(withEvent: .episodeDeleted)
        }
    }
    
    func getEpisodeRecord(_ episode: Episode) -> Promise<Data> {
        return Promise.value.then {
            self.storage.getEpisodeRecord(episode)
        }
    }
    
    func getEpisodesInfo() -> Promise<[Episode]> {
        return Promise.value.then {
            self.storage.getStoredEpisodesInfo()
        }
    }
    
    func subscribe(_ subscriber: @escaping (Event) -> Void) -> Subscription {
        let key = UUID.init()
        subscribers[key] = subscriber
        return Subscription { [weak self] in self?.subscribers.removeValue(forKey: key) }
    }
    
    // MARK: -  helpers
    fileprivate func notifyAll(withEvent event: Event) {
        subscribers.values.forEach { $0(event) }
    }
}
