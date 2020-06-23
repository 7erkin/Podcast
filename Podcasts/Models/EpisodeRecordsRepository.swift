//
//  EpisodeRecordDownloader.swift
//  Podcasts
//
//  Created by Олег Черных on 23/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation 
import PromiseKit

final class EpisodeRecordsRepository: EpisodeRecordRepositoring {
    private(set) var downloadingEpisodes: OrderedDictionary<Episode, Double> = [:]
    private var subscribers = Subscribers<EpisodeRecordRepositoryEvent>()
    private var downloadingRecordCancellers: [Episode:AsyncOperationCanceller] = [:]
    // MARK: - dependencies
    var recordStorage: EpisodeRecordStoraging
    var recordFetcher: EpisodeRecordFetching
    // MARK: -
    init(recordStorage: EpisodeRecordStoraging, recordFetcher: EpisodeRecordFetching) {
        self.recordStorage = recordStorage
        self.recordFetcher = recordFetcher
    }
    // MARK: - EpisodeRecordRepositoring impl
    func remove(recordDescriptor: EpisodeRecordDescriptor) {
        firstly {
            recordStorage.removeRecord(recordDescriptor)
        }.done {
            self.subscribers.fire(.removed(recordDescriptor, $0))
        }.catch { _ in }
    }
    
    func downloadRecord(ofEpisode episode: Episode, ofPodcast podcast: Podcast) {
        let progressHandler: (Double) -> Void = { _ in }
        let canceller = recordFetcher.fetchEpisodeRecord(episode: episode, progressHandler) { recordData in
            self.downloadingEpisodes.removeValue(forKey: episode)
            firstly {
                self.recordStorage.saveRecord(recordData, ofEpisode: episode, ofPodcast: podcast)
            }.done {
                self.subscribers.fire(.downloadingFulfilled(episode, self.downloadingEpisodes, $0))
            }.catch { _ in }
        }
        downloadingRecordCancellers[episode] = canceller
    }
    
    func cancelDownloadingRecord(ofEpisode episode: Episode) {
        if let canceller = downloadingRecordCancellers.removeValue(forKey: episode) {
            canceller.cancel()
            downloadingEpisodes.removeValue(forKey: episode)
            subscribers.fire(.downloadingCancelled(episode, downloadingEpisodes))
        }
    }
    
    func subscribe(_ subscriber: @escaping (EpisodeRecordRepositoryEvent) -> Void) -> Subscription {
        firstly {
            recordStorage.getEpisodeRecordDescriptors(withSortPolicy: { _, _ in return true })
        }.done {
            subscriber(.initial($0, self.downloadingEpisodes))
        }.catch { _ in }
        return subscribers.subscribe(action: subscriber)
    }
}
