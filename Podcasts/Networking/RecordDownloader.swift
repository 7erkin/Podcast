//
//  EpisodeRecordDownloader.swift
//  Podcasts
//
//  Created by Олег Черных on 13/07/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit

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

final class RecordDownloader: NSObject, EpisodeRecordDownloading, URLSessionDelegate {
    private let downloadServiceQueue = DispatchQueue(
        label: "download.service.queue",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem,
        target: nil
    )
    private var activeDownloads: [URL:Download<EpisodeRecordDownloading.Handler>] = [:]
    private lazy var backgroundSession: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "itunes.backgroundsession")
        configuration.sessionSendsLaunchEvents = true
        configuration.allowsCellularAccess = true
        configuration.shouldUseExtendedBackgroundIdleMode = true
        configuration.waitsForConnectivity = true
        configuration.isDiscretionary = false
        return URLSession(
            configuration: configuration,
            delegate: self,
            delegateQueue: nil
        )
    }()
    private let scheduler: BackgroundSessionScheduler
    init(backgroundTaskScheduler scheduler: BackgroundSessionScheduler) {
        self.scheduler = scheduler
    }
    
    func downloadEpisodeRecord(
        episode: Episode,
        _ block: @escaping EpisodeRecordDownloading.Handler
    ) -> DownloadManager {
        let download = Download(episode: episode, downloadHandler: block)
        let session = URLSession(configuration: .default)
        download.task = session.downloadTask(with: episode.streamUrl)
        download.task?.resume()
        block(.event(.started))
        downloadServiceQueue.async { [weak self] in
            self?.activeDownloads[episode.streamUrl] = download
        }
        let cancel: DownloadManager.Handler = { [weak self] in
            self?.downloadServiceQueue.async {
                if let download = self?.activeDownloads.removeValue(forKey: episode.streamUrl) {
                    download.task?.cancel()
                    download.handler(.event(.canceled))
                }
            }
        }
        let suspend: DownloadManager.Handler = { [weak self] in
            self?.downloadServiceQueue.async {
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
            self?.downloadServiceQueue.async {
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
        return DownloadManager(cancel: cancel, resume: resume, suspend: suspend)
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
                downloadServiceQueue.async { [weak self] in
                    let download = self?.activeDownloads.removeValue(forKey: url)
                    download?.handler(.event(.fulfilled(temporaryUrl)))
                }
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
        if let url = downloadTask.originalRequest?.url {
            let progress = Double((100 * totalBytesWritten) / totalBytesExpectedToWrite) / 100
            downloadServiceQueue.async { [weak self] in
                let download = self?.activeDownloads[url]
                download?.handler(.event(.inProgress(progress)))
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let url = task.originalRequest?.url {
            downloadServiceQueue.async { [weak self] in
                if let download = self?.activeDownloads[url] {
                    // must be correct
                    download.handler(.failure(.init(.cancelled)))
                }
            }
        }
    }
}
