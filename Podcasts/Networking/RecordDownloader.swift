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

final class RecordDownloader:
NSObject, EpisodeRecordDownloading, URLSessionDelegate, BackgroundSessionSchedulable {
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
    private lazy var defaultSession: URLSession = { [unowned self] in
        return URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue.current)
    }()
    private let scheduler: BackgroundSessionScheduler
    init(backgroundSessionScheduler scheduler: BackgroundSessionScheduler) {
        self.scheduler = scheduler
    }
    
    func downloadEpisodeRecord(
        episode: Episode,
        _ block: @escaping EpisodeRecordDownloading.Handler
    ) -> Promise<DownloadManager> {
        let download = Download(episode: episode, downloadHandler: block)
        return firstly {
            // scheduler.register(self)
            return Promise { resolver in resolver.fulfill({}) }
        }.then(on: serviceQueue, flags: nil) { registrationCanceller -> Promise<DownloadManager> in
            download.task = self.backgroundSession.downloadTask(with: episode.streamUrl)
            download.task?.resume()
            block(.event(.started))
            self.activeDownloads[episode.streamUrl] = download
            let cancel: DownloadManager.Handler = { [weak self] in
                self?.serviceQueue.async {
                    registrationCanceller()
                    if let download = self?.activeDownloads.removeValue(forKey: episode.streamUrl) {
                        download.task?.cancel()
                        download.handler(.event(.canceled))
                    }
                }
            }
            let suspend: DownloadManager.Handler = { [weak self] in
                self?.serviceQueue.async {
                    registrationCanceller()
                    if let download = self?.activeDownloads[episode.streamUrl], download.isDownloading {
                        download.isDownloading = false
                        download.task?.cancel(byProducingResumeData: {
                            download.resumeData = $0
                        })
                        download.task = nil
                        download.handler(.event(.suspended))
                    }
                }
            }
            let resume: DownloadManager.Handler = { [weak self] in
                self?.serviceQueue.async {
                    if let download = self?.activeDownloads[episode.streamUrl], !download.isDownloading {
                        if let data = download.resumeData {
                            download.task = self?.backgroundSession.downloadTask(withResumeData: data)
                        } else {
                            download.task = self?.backgroundSession.downloadTask(with: episode.streamUrl)
                        }
                        download.isDownloading = true
                        download.handler(.event(.resumed))
                    }
                }
            }
            return Promise { $0.fulfill(DownloadManager(cancel: cancel, resume: resume, suspend: suspend)) }
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
}
