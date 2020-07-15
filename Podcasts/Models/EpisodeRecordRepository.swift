//
//  EpisodeRecordDownloader.swift
//  Podcasts
//
//  Created by Олег Черных on 23/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation 
import PromiseKit

final class EpisodeRecordRepository: EpisodeRecordRepositoring {
    private(set) var downloads: EpisodesDownloads
    private var subscribers = Subscribers<EpisodeRecordRepositoryEvent>()
    private var downloadManagers: [Episode:DownloadManager] = [:]
    // MARK: - dependencies
    private let recordStorage: EpisodeRecordStoraging
    private let recordDownloader: EpisodeRecordDownloading
    // MARK: -
    init(recordStorage: EpisodeRecordStoraging, recordFetcher: EpisodeRecordDownloading) {
        downloads = .init()
        self.recordStorage = recordStorage
        self.recordDownloader = recordFetcher
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
        downloadManagers[episode] = recordDownloader.downloadEpisodeRecord(episode: episode) { [weak self] in
            guard let self = self else { return }
            
            if case .event(let event) = $0 {
                switch event {
                case .fulfilled(let url):
                    if let index = self.downloads.active.firstIndex(where: episode) {
                        self.downloads.active.remove(at: index)
                    }
                    firstly {
                        return self.recordStorage.saveRecord(withUrl: url, ofEpisode: episode, ofPodcast: podcast)
                    }.done {
                        self.downloads.fulfilled = $0
                        self.subscribers.fire(.downloadFulfilled(episode, podcast, self.downloads))
                    }.catch { _ in print("Err!") }
                case .inProgress(let progress):
                    if let index = self.downloads.active.firstIndex(where: { $0.episode == episode }) {
                        self.downloads.active[index].progress = progress
                        self.subscribers.fire(.download(self.downloads))
                    }
                case .started:
                    self.downloads.active.append(.init(episode: episode, podcast: podcast, progress: 0))
                    self.subscribers.fire(.downloadStarted(episode, podcast, self.downloads))
                case .canceled:
                    self.downloads.active.remove(where: episode)
                    self.subscribers.fire(.downloadCancelled(episode, podcast, self.downloads))
                case .suspended:
                    if let download = self.downloads.active.remove(where: episode) {
                        self.downloads.suspended.append(download)
                        self.subscribers.fire(.downloadSuspended(episode, podcast, self.downloads))
                    }
                case .resumed:
                    if let download = self.downloads.suspended.remove(where: episode) {
                        self.downloads.active.append(download)
                        self.subscribers.fire(.downloadResumed(episode, podcast, self.downloads))
                    }
                }
            }
        }
    }
    
    func pauseDownloadRecord(ofEpisode episode: Episode) {
        downloadManagers[episode]?.suspend()
    }
    
    func resumeDownloadRecord(ofEpisode episode: Episode) {
        downloadManagers[episode]?.resume()
    }
    
    func cancelDownloadRecord(ofEpisode episode: Episode) {
        downloadManagers.removeValue(forKey: episode)?.cancel()
    }
    
    func subscribe(_ subscriber: @escaping (EpisodeRecordRepositoryEvent) -> Void) -> Subscription {
        subscriber(.initial(self.downloads))
        return subscribers.subscribe(action: subscriber)
    }
}
