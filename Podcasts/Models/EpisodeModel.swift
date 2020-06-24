//
//  EpisodeCellModel.swift
//  Podcasts
//
//  Created by Олег Черных on 03/06/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

enum EpisodeDownloadingStatus {
    case notStarted
    case inProgress(Double)
    case downloaded
    case finishedWithError
    case finishedWithCancelation
}

enum EpisodeModelEvent {
    case initial(Episode, EpisodeDownloadingStatus)
    case episodeDownloadingStatusChanged(EpisodeDownloadingStatus)
}

final class EpisodeModel {
    private var subscriptions: [Subscription] = []
    private var subscribers = Subscribers<EpisodeModelEvent>()
    let episode: Episode
    private let podcast: Podcast
    private var episodeDownloadingStatus: EpisodeDownloadingStatus = .notStarted {
        didSet {
            subscribers.fire(.episodeDownloadingStatusChanged(self.episodeDownloadingStatus))
        }
    }
    private let recordRepository: EpisodeRecordRepositoring
    init(episode: Episode, podcast: Podcast, recordRepository: EpisodeRecordRepositoring) {
        self.episode = episode
        self.podcast = podcast
        self.recordRepository = recordRepository
        self.recordRepository
            .subscribe { [weak self] in self?.updateWithRecordRepository($0) }
            .stored(in: &subscriptions)
    }
    
    func downloadEpisode() {
        recordRepository.downloadRecord(ofEpisode: episode, ofPodcast: podcast)
    }
    
    func cancelEpisodeDownloading() {
        recordRepository.cancelDownloadingRecord(ofEpisode: episode)
    }
    
    private func updateWithRecordRepository(_ event: EpisodeRecordRepositoryEvent) {
        switch event {
        case .initial(let recordDescriptors, let downloadingEpisodes):
            if let _ = recordDescriptors.first(where: { $0.episode == episode }) {
                episodeDownloadingStatus = .downloaded
            } else {
                if let progress = downloadingEpisodes[episode]?.progress {
                    episodeDownloadingStatus = .inProgress(progress)
                } else {
                    episodeDownloadingStatus = .notStarted
                }
            }
        case .downloadingCancelled(let episode, _):
            if episode == self.episode {
                episodeDownloadingStatus = .finishedWithCancelation
            }
        case .downloadingFulfilled(let episode, _, _):
            if episode == self.episode {
                episodeDownloadingStatus = .downloaded
            }
        case .removed(let recordDescriptor, _):
            if recordDescriptor.episode == self.episode {
                episodeDownloadingStatus = .notStarted
            }
        case .downloadingStarted(let episode, _):
            if episode == self.episode {
                episodeDownloadingStatus = .inProgress(0)
            }
        case .downloading(let downloadEpisodes):
            if let progress = downloadEpisodes[episode]?.progress {
                episodeDownloadingStatus = .inProgress(progress)
            }
        }
    }

    func subscribe(_ subscriber: @escaping (EpisodeModelEvent) -> Void) -> Subscription {
        subscriber(.initial(episode, episodeDownloadingStatus))
        return subscribers.subscribe(action: subscriber)
    }
}
