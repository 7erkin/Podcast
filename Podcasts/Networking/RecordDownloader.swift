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

final class RecordDownloader: NSObject, EpisodeRecordDownloading, URLSessionDownloadDelegate {
    private var activeDownloads: [URL:Download<EpisodeRecordDownloading.Handler>] = [:]
    private lazy var foregroundSession: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    private lazy var backgroundSession: URLSession = { [unowned self] in
        let configuration = URLSessionConfiguration.background(withIdentifier: "background.session")
        configuration.sessionSendsLaunchEvents = true
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    func downloadEpisodeRecord(
        episode: Episode,
        _ block: @escaping EpisodeRecordDownloading.Handler
    ) -> DownloadManager {
        let download = Download(episode: episode, downloadHandler: block)
        self.activeDownloads[episode.streamUrl] = download
        let request = URLRequest(
            url: episode.streamUrl,
            cachePolicy: .returnCacheDataElseLoad,
            timeoutInterval: 5.0
        )
        download.task = self.foregroundSession.downloadTask(with: request)
        download.task?.resume()
        block(.event(.started))
        return DownloadManager(
            cancel: self.createCancelHandler(forDownload: download),
            resume: self.createResumeHandler(forDownload: download),
            suspend: self.createSuspendHandler(forDownload: download)
        )
    }
    
    // MARK: - URLSessionDownloadDelegate
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        if
            let url = downloadTask.originalRequest?.url,
            let temporaryUrl = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent(location.lastPathComponent)
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
    
    private func createCancelHandler(
        forDownload download: Download<EpisodeRecordDownloading.Handler>
    ) -> DownloadManager.Handler {
        { [weak self] in
           self?.activeDownloads.removeValue(forKey: download.episode.streamUrl)
            download.task?.cancel()
            download.handler(.event(.canceled))
        }
    }
    
    private func createSuspendHandler(
        forDownload download: Download<EpisodeRecordDownloading.Handler>
    ) -> DownloadManager.Handler {
        {
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
