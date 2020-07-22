//
//  EpisodeRecordDownloader.swift
//  Podcasts
//
//  Created by Олег Черных on 13/07/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit
import Combine

final class EpisodeRecordDownloader: NSObject, EpisodeRecordDownloading {
    var _publisher = PassthroughSubject<EpisodeRecordDownloaderEvent, Never>()
    var state = EpisodeRecordDownloaderState(downloads: [])
    var foregroundTasks: [URL:URLSessionDownloadTask] = [:]
    lazy var foregroundSession: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    let backgroundSessionIdentifier = "record.downloader.background.session"
    lazy var backgroundSession: URLSession = { [unowned self] in
        let configuration = URLSessionConfiguration.background(withIdentifier: "background.session")
        configuration.sessionSendsLaunchEvents = true
        configuration.allowsCellularAccess = true
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        configuration.isDiscretionary = true
        configuration.timeoutIntervalForRequest = .greatestFiniteMagnitude
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    let scheduler: SessionScheduler
    init(sessionScheduler scheduler: SessionScheduler) {
        self.scheduler = scheduler
        super.init()
        self.transitToForegroundSessionExecution()
    }
    
    var publisher: AnyPublisher<EpisodeRecordDownloaderEvent, Never> {
        _publisher.eraseToAnyPublisher()
    }
    
    func downloadEpisodeRecord(_ episode: Episode) {
        assert(Thread.isMainThread, "\(#function) should call on main thread")
        scheduler.register(client: self)
        let task = foregroundSession.downloadTask(with: episode.streamUrl.downloadRequest)
        task.resume()
        foregroundTasks[episode.streamUrl] = task
        let download = EpisodeDownload(episode: episode, progress: 0)
        state.downloads.append(download)
        emit(.started(episode, state))
    }
    
    func cancelEpisodeRecordDownload(_ episode: Episode) {
        assert(Thread.isMainThread, "\(#function) should call on main thread")
        if let task = foregroundTasks.removeValue(forKey: episode.streamUrl) {
            task.cancel()
            if let index = self.state.downloads.firstIndex(where: { $0.episode == episode }) {
                self.state.downloads.remove(at: index)
            }
            self.emit(.cancelled(episode, self.state))
        }
    }
    // MARK: - Helpers
    func emit(_ event: EpisodeRecordDownloaderEvent) {
        assert(Thread.isMainThread, "\(#function) should call on main thread")
        _publisher.send(event)
    }
}

private extension URL {
    var downloadRequest: URLRequest {
        URLRequest(
            url: self,
            cachePolicy: .returnCacheDataElseLoad,
            timeoutInterval: .greatestFiniteMagnitude
        )
    }
}
