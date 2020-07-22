//
//  EpisodeRecordDownloader.swift
//  Podcasts
//
//  Created by Олег Черных on 23/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation 
import PromiseKit
import Combine

final class EpisodeRecordRepository: EpisodeRecordRepositoring {
    private(set) var downloads: [EpisodeDownload]
    private var subscribers = Subscribers<EpisodeRecordRepositoryEvent>()
    private var subscriptions: Set<AnyCancellable> = []
    // MARK: - dependencies
    private let recordStorage: EpisodeRecordStoraging
    private let recordDownloader: EpisodeRecordDownloading
    // MARK: -
    init(recordStorage: EpisodeRecordStoraging, recordDownloader: EpisodeRecordDownloading) {
        downloads = .init()
        self.recordStorage = recordStorage
        self.recordDownloader = recordDownloader
        self.recordDownloader
            .publisher
            .sink { [weak self] in self?.updateWithRecordDownloader($0) }
            .store(in: &subscriptions)
        
        firstly {
            recordStorage.getEpisodeRecordDescriptors(withSortPolicy: { $0.dateOfCreate > $1.dateOfCreate })
        }.done {
            self.downloads.fulfilled = $0
            self.subscribers.fire(.initial(self.downloads))
        }.catch { _ in }
    }
    // MARK: - EpisodeRecordRepositoring impl
    func remove(recordDescriptor: EpisodeRecordDescriptor) {
        firstly {
            recordStorage.removeRecord(recordDescriptor)
        }.done {
            self.downloads.fulfilled = $0
            self.subscribers.fire(.removed(recordDescriptor, self.downloads))
        }.catch { _ in }
    }
    
    func downloadRecord(ofEpisode episode: Episode, ofPodcast podcast: Podcast) {
        recordDownloader.downloadEpisodeRecord(episode)
    }
    
    func cancelDownloadRecord(ofEpisode episode: Episode) {
        recordDownloader.cancelEpisodeRecordDownload(episode)
    }
    
    func subscribe(_ subscriber: @escaping (EpisodeRecordRepositoryEvent) -> Void) -> Subscription {
        subscriber(.initial(self.downloads))
        return subscribers.subscribe(action: subscriber)
    }
    
    private func updateWithRecordDownloader(_ event: EpisodeRecordDownloaderEvent) {
        switch event {
        case .recovered(let episodes, let state):
            downloads.active = state.downloads
        case .progressUpdated(let episode, let state):
            break
        case .started(let episode, let state):
            break
        case .fulfilled(let episode, let url, let state):
            break
        case .cancelled(let episode, let state):
            break
        }
    }
}
