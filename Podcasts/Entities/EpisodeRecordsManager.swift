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
    
    private let storage: EpisodeRecordsStoraging
    private let recordFetcher: EpisodeRecordFetching
    private let serviceQueue: DispatchQueue
    // how to constraint serviceQueue to serial queue? Smth as constraint or assert
    init(on serviceQueue: DispatchQueue, storage: EpisodeRecordsStoraging, recordFetcher: EpisodeRecordFetching) {
        self.storage = storage
        self.recordFetcher = recordFetcher
        self.serviceQueue = serviceQueue
    }
    
    private var subscribers: [UUID:(Event) -> Void] = [:]
    func save(episode: Episode) {
        _ = Promise.value.then(on: serviceQueue, flags: nil) {
            self.recordFetcher.fetch(episode: episode) { [weak self] progress in
                self?.serviceQueue.async { self?.notifyAll(withEvent: .episodeDownloadingProgress(episode: episode, progress: progress)) }
            }
        }.then(on: serviceQueue, flags: nil) { data in
            self.storage.save(episode: episode, withRecord: data)
        }.done(on: serviceQueue, flags: nil) {
            self.notifyAll(withEvent: .episodeSaved)
        }
    }
    
    func delete(episode: Episode) {
        _ = Promise.value.done(on: serviceQueue, flags: nil) {
            self.storage.delete(episode: episode)
        }.done(on: serviceQueue, flags: nil) {
            self.notifyAll(withEvent: .episodeDeleted)
        }
    }
    
    func getEpisodeRecord(_ episode: Episode) -> Promise<Data> {
        return Promise.value.then(on: serviceQueue, flags: nil) {
            self.storage.getEpisodeRecord(episode)
        }
    }
    
    func getEpisodesInfo() -> Promise<[Episode]> {
        return Promise.value.then(on: serviceQueue, flags: nil) {
            self.storage.getStoredEpisodesInfo()
        }
    }
    
    func subscribe(_ subscriber: @escaping (Event) -> Void) -> Subscription {
        let key = UUID.init()
        subscribers[key] = subscriber
        return Subscription(canceller: { [unowned self] in self.subscribers.removeValue(forKey: key) })
    }
    
    // MARK: -  helpers
    fileprivate func notifyAll(withEvent event: Event) {
        subscribers.values.forEach { $0(event) }
    }
}
