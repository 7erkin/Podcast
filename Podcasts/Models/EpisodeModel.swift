//
//  EpisodeCellModel.swift
//  Podcasts
//
//  Created by Олег Черных on 03/06/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

enum EpisodeDownloadStatus {
    case downloadNotLaunched
    case inProgress(Double)
    case downloaded
    case finishedWithError
    case finishedWithCancelation
}

enum EpisodeModelEvent {
    case initial(Episode, EpisodeDownloadStatus)
    case episodeDownloadingStatusChanged(EpisodeDownloadStatus)
}

final class EpisodeModel {
    private var subscriptions: [Subscription] = []
    private var subscribers = Subscribers<EpisodeModelEvent>()
    let episode: Episode
    private let podcast: Podcast
    private var downloadStatus: EpisodeDownloadStatus = .downloadNotLaunched {
        didSet {
            subscribers.fire(.episodeDownloadingStatusChanged(self.downloadStatus))
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
        recordRepository.cancelDownloadRecord(ofEpisode: episode)
    }
    
    private func updateWithRecordRepository(_ event: EpisodeRecordRepositoryEvent) {
        switch event {
        case .initial(let episodesDownloads):
            if let download = episodesDownloads.active.first(where: { $0.episode == episode }) {
                downloadStatus = .inProgress(download.progress)
            } else {
                if episodesDownloads.fulfilled.contains(where: { $0.episode == episode }) {
                    downloadStatus = .downloaded
                } else {
                    downloadStatus = .downloadNotLaunched
                }
            }
        case .downloadStarted(let episode, _, let episodesDownloads):
            if self.episode == episode {
                if let progress = episodesDownloads.active.first(where: { $0.episode == episode })?.progress {
                    downloadStatus = .inProgress(progress)
                }
            }
        case .downloadCancelled(let episode, _, _):
            if self.episode == episode {
                downloadStatus = .downloadNotLaunched
            }
        case .download(let episodesDownloads):
            if let progress = episodesDownloads.active.first(where: { $0.episode == episode })?.progress {
                downloadStatus = .inProgress(progress)
            }
        case .downloadFulfilled(let episode, _, _):
            if self.episode == episode {
                downloadStatus = .downloaded
            }
        case .removed(let recordDescriptor, _):
            if episode == recordDescriptor.episode {
                downloadStatus = .downloadNotLaunched
            }
        default:
            break
        }
    }

    func subscribe(_ subscriber: @escaping (EpisodeModelEvent) -> Void) -> Subscription {
        subscriber(.initial(episode, downloadStatus))
        return subscribers.subscribe(action: subscriber)
    }
}
