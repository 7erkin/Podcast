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
    private var subscribers = Subscribers<EpisodeRecordRepositoryEvent>()
    private var subscriptions: Set<AnyCancellable> = []
    private var state = EpisodeRecordRepositoryState()
    private var episodeToPodcast: [Episode:Podcast] = [:]
    // MARK: - dependencies
    private let recordStorage: EpisodeRecordStoraging
    private let recordDownloader: EpisodeRecordDownloading
    // MARK: -
    init(recordStorage: EpisodeRecordStoraging, recordDownloader: EpisodeRecordDownloading) {
        state = .init()
        self.recordStorage = recordStorage
        self.recordDownloader = recordDownloader
        self.recordDownloader
            .publisher
            .sink { [weak self] in self?.updateWithRecordDownloader($0) }
            .store(in: &subscriptions)
        
        firstly {
            recordStorage.getEpisodeRecordDescriptors(withSortPolicy: { $0.dateOfCreate > $1.dateOfCreate })
        }.done {
            self.state.localDownloads = $0
            self.subscribers.fire(.initial(self.state))
        }.catch { _ in }
    }
    // MARK: - EpisodeRecordRepositoring impl
    func remove(recordDescriptor: EpisodeRecordDescriptor) {
        firstly {
            recordStorage.removeRecord(recordDescriptor)
        }.done {
            self.state.localDownloads = $0
            self.subscribers.fire(.removed(recordDescriptor, self.state))
        }.catch { _ in }
    }
    
    func downloadRecord(ofEpisode episode: Episode, ofPodcast podcast: Podcast) {
        episodeToPodcast[episode] = podcast
        recordDownloader.downloadEpisodeRecord(episode)
    }
    
    func cancelDownloadRecord(ofEpisode episode: Episode) {
        recordDownloader.cancelEpisodeRecordDownload(episode)
    }
    
    func subscribe(_ subscriber: @escaping (EpisodeRecordRepositoryEvent) -> Void) -> Subscription {
        subscriber(.initial(self.state))
        return subscribers.subscribe(action: subscriber)
    }
    
    private func updateWithRecordDownloader(_ event: EpisodeRecordDownloaderEvent) {
        switch event {
        case .recovered(_, let state):
            self.state.activeDownloads = state.downloads
        case .progressUpdated(_, let state):
            self.state.activeDownloads = state.downloads
            subscribers.fire(.download(self.state))
        case .started(let episode, let state):
            self.state.activeDownloads = state.downloads
            subscribers.fire(.downloadStarted(episode, episodeToPodcast[episode]!, self.state))
        case .fulfilled(let episode, let url, let state):
            self.state.activeDownloads = state.downloads
            firstly {
                self.recordStorage.saveRecord(withUrl: url, ofEpisode: episode, ofPodcast: episodeToPodcast[episode]!)
            }.done {
                self.state.localDownloads = $0
                self.subscribers.fire(.downloadFulfilled(episode, self.episodeToPodcast[episode]!, self.state))
            }.catch { _ in }
        case .cancelled(let episode, let state):
            self.state.activeDownloads = state.downloads
            subscribers.fire(.downloadCancelled(episode, episodeToPodcast[episode]!, self.state))
        }
    }
}
