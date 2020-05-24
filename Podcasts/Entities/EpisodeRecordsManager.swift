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

class EpisodeRecordsManager {
    enum Event {
        case episodeSaved(episode: Episode)
        case episodeDeleted(episode: Episode)
        case episodeSavingProgress(episode: Episode, progress: Double)
    }
    
    var recordsStorage: EpisodeRecordsStoraging!
    var recordFetcher: EpisodeRecordFetching!
    private var subscribers: [UUID:(Event) -> Void] = [:]
    static let shared = EpisodeRecordsManager()
    private init() {}
    
    func isEpisodeSaved(_ episode: Episode) -> Promise<Bool> {
        return recordsStorage.hasEpisode(episode)
    }
    
    func saveEpisode(_ episode: Episode, ofPodcast podcast: Podcast) {
        firstly {
            recordsStorage.hasEpisode(episode)
        }.then { hasEpisode -> Promise<Data> in
            if hasEpisode { return Promise(error: BreakPromiseChainError()) }
            return self.recordFetcher.fetch(episode: episode) { progress in
                DispatchQueue.main.async { [weak self] in
                    self?.notifyAll(withEvent: .episodeSavingProgress(episode: episode, progress: progress))
                }
            }
        }.then { data in
            self.recordsStorage.save(episode: episode, ofPodcast: podcast, withRecord: data)
        }.done {
            self.notifyAll(withEvent: .episodeSaved(episode: episode))
        }.catch { _ in
            
        }
    }
    
    func deleteEpisode(_ episode: Episode) {
        firstly {
            recordsStorage.delete(episode: episode)
        }.done {
            // notify
        }.catch { _ in
            
        }
    }
    
    var storedEpisodes: Promise<[StoredEpisodeRecordItem]> {
        return recordsStorage.getStoredEpisodeRecordList()
    }
    
    func subscribe(_ subscriber: @escaping (Event) -> Void) -> Subscription {
        let key = UUID.init()
        subscribers[key] = subscriber
        return Subscription { [weak self] in
            self?.subscribers.removeValue(forKey: key)
        }
    }
    
    fileprivate func notifyAll(withEvent event: Event) {
        subscribers.values.forEach { $0(event) }
    }
}
