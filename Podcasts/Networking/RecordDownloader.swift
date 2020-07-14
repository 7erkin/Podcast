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

final class Download<DownloadHandler> {
    var task: URLSessionDownloadTask?
    var resumeData: Data?
    var isDownloading: Bool = false
    let episode: Episode
    let handler: DownloadHandler
    init(episode: Episode, downloadHandler: DownloadHandler) {
        self.episode = episode
        self.handler = downloadHandler
    }
}

final class RecordDownloader: NSObject, EpisodeRecordDownloading, URLSessionDelegate, URLSessionSchedulable {
    func backgroundTransit() {
        print(#function)
        for download in activeDownloads.values {
            download.task?.cancel { [weak self] data in
                download.resumeData = data
                if let data = data {
                    download.task = self?.backgroundSession.downloadTask(withResumeData: data)
                } else {
                    download.task = self?.backgroundSession.downloadTask(with: download.episode.streamUrl)
                }
                download.task?.resume()
            }
        }
    }
    
    func foregroundTransit() {
        print(#function)
        backgroundSession.getAllTasks { tasks in
            print(tasks.count)
        }
    }
    
    func handleSessionEvent(_ completionHandler: @escaping () -> Void) {
        print(#function)
    }
    
    var sessionId: String { "itunes.backgroundsession" }
    
    private let serviceQueue = DispatchQueue(
        label: "download.service.queue",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem,
        target: nil
    )
    private var activeDownloads: [URL:Download<EpisodeRecordDownloading.Handler>] = [:]
    private lazy var backgroundSession: URLSession = { [unowned self] in
        let configuration = URLSessionConfiguration.background(withIdentifier: self.sessionId)
        configuration.sessionSendsLaunchEvents = true
        configuration.allowsCellularAccess = true
        configuration.shouldUseExtendedBackgroundIdleMode = true
        configuration.waitsForConnectivity = true
        configuration.isDiscretionary = false
        return URLSession(
            configuration: configuration,
            delegate: self,
            delegateQueue: OperationQueue.current
        )
    }()
    private lazy var foregroundSession: URLSession = { [unowned self] in
        return URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue.current)
    }()
    private let scheduler: URLSessionScheduler
    private var schedulerRegistrationCanceller: URLSessionScheduler.ResignSchedulerClient?
    init(backgroundSessionScheduler scheduler: URLSessionScheduler) {
        self.scheduler = scheduler
        super.init()
        initializeWithBackgroundSession()
    }
    
    private func initializeWithBackgroundSession() {
        backgroundSession.getAllTasks { tasks in
            for task in tasks {
                if let downloadTask = task as? URLSessionDownloadTask {
                    downloadTask.cancel { [weak self] data in
                        self?.serviceQueue.async {
                            if let data = data {
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func addToBackgroundSessionSchedulerIfNeeded() {
        if schedulerRegistrationCanceller == nil {
            schedulerRegistrationCanceller = try? scheduler.becomeSchedulerClient(self).wait()
        }
    }
    
    private func removeFromBackgroundSessionScheduler() {
        schedulerRegistrationCanceller?()
    }
    
    func downloadEpisodeRecord(
        episode: Episode,
        _ block: @escaping EpisodeRecordDownloading.Handler
    ) -> Promise<DownloadManager> {
        return Promise { resolver in
            serviceQueue.async { [unowned self] in
                let download = Download(episode: episode, downloadHandler: block)
                self.activeDownloads[episode.streamUrl] = download
                self.addToBackgroundSessionSchedulerIfNeeded()
                download.task = self.foregroundSession.downloadTask(with: episode.streamUrl)
                download.task?.resume()
                block(.event(.started))
                let manager = DownloadManager(
                    cancel: self.createCancelHandler(forDownload: download),
                    resume: self.createResumeHandler(forDownload: download),
                    suspend: self.createSuspendHandler(forDownload: download)
                )
                resolver.fulfill(manager)
            }
        }
    }
    
    // MARK: - URLSessionDownloadDelegate
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        if
            let url = downloadTask.originalRequest?.url,
            let temporaryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(location.lastPathComponent)
        {
            do {
                try FileManager.default.moveItem(at: location, to: temporaryUrl)
                let download = activeDownloads.removeValue(forKey: url)
                if activeDownloads.isEmpty {
                    removeFromBackgroundSessionScheduler()
                }
                download?.handler(.event(.fulfilled(temporaryUrl)))
            } catch let err {
                print("Error during move: ", err)
            }
        }
    }
    
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        print(totalBytesWritten)
        if let url = downloadTask.originalRequest?.url {
            let progress = Double((100 * totalBytesWritten) / totalBytesExpectedToWrite) / 100
            let download = activeDownloads[url]
            download?.handler(.event(.inProgress(progress)))
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let url = task.originalRequest?.url {
            if let download = activeDownloads[url] {
                // must be correct
                download.handler(.failure(.init(.cancelled)))
            }
        }
    }
    // MARK: - Helpers
    private func createResumeHandler(
        forDownload download: Download<EpisodeRecordDownloading.Handler>
    ) -> DownloadManager.Handler {
        { [weak self] in
            self?.serviceQueue.async {
                if !download.isDownloading {
                    if let data = download.resumeData {
                        download.task = self?.foregroundSession.downloadTask(withResumeData: data)
                    } else {
                        download.task = self?.foregroundSession.downloadTask(with: download.episode.streamUrl)
                    }
                    download.isDownloading = true
                    download.handler(.event(.resumed))
                }
            }
        }
    }
    
    private func createCancelHandler(
        forDownload download: Download<EpisodeRecordDownloading.Handler>
    ) -> DownloadManager.Handler {
        { [weak self] in
            self?.serviceQueue.async {
                self?.activeDownloads.removeValue(forKey: download.episode.streamUrl)
                download.task?.cancel()
                if let isEmpty = self?.activeDownloads.isEmpty, isEmpty {
                    self?.removeFromBackgroundSessionScheduler()
                }
                download.handler(.event(.canceled))
            }
        }
    }
    
    private func createSuspendHandler(
        forDownload download: Download<EpisodeRecordDownloading.Handler>
    ) -> DownloadManager.Handler {
        { [weak self] in
            self?.serviceQueue.async {
                if download.isDownloading {
                    download.isDownloading = false
                    download.task?.cancel(byProducingResumeData: {
                        download.resumeData = $0
                    })
                    download.task = nil
                    download.handler(.event(.suspended))
                }
            }
        }
    }
}
