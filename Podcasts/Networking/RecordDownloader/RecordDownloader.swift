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

final class RecordDownloader: NSObject, EpisodeRecordDownloading {
    var activeDownloads: [URL:Download<EpisodeRecordDownloading.Handler>] = [:]
    lazy var foregroundSession: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    let backgroundSessionIdentifier = "record.downloader.background.session"
    lazy var backgroundSession: URLSession = { [unowned self] in
        let configuration = URLSessionConfiguration.background(withIdentifier: "background.session")
        configuration.sessionSendsLaunchEvents = true
        configuration.allowsCellularAccess = true
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        configuration.isDiscretionary = false
        configuration.timeoutIntervalForRequest = 5.0
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    let serviceQueue = DispatchQueue.main
    let scheduler: URLSessionScheduler
    var resignSchedulerClient: URLSessionScheduler.ResignSchedulerClient?
    init(urlSessionScheduler scheduler: URLSessionScheduler) {
        self.scheduler = scheduler
    }
    
    func downloadEpisodeRecord(
        episode: Episode,
        _ block: @escaping EpisodeRecordDownloading.Handler
    ) -> Promise<DownloadManager> {
        return Promise { resolver in
            serviceQueue.async { [weak self] in
                guard let self = self else { return }
                
                firstly {
                    self.scheduler.isSchedulerClient(self)
                }.then(on: self.serviceQueue, flags: nil) { isClient -> Promise<Void> in
                    if isClient {
                        return Promise.value
                    }
                    
                    return Promise { resolver in
                        firstly {
                            self.scheduler.becomeSchedulerClient(self)
                        }.done(on: self.serviceQueue, flags: nil) {
                            self.resignSchedulerClient = $0
                            resolver.fulfill(())
                        }.catch { _ in }
                    }
                }.done(on: self.serviceQueue, flags: nil) {
                    let download = Download(episode: episode, downloadHandler: block)
                    self.activeDownloads[episode.streamUrl] = download
                    let request = URLRequest(
                        url: episode.streamUrl,
                        cachePolicy: .returnCacheDataElseLoad,
                        timeoutInterval: 10.0
                    )
                    download.task = self.foregroundSession.downloadTask(with: request)
                    download.task?.resume()
                    block(.event(.started))
                    //exit(1)
                    let manager = DownloadManager(
                        cancel: self.createCancelHandler(forDownload: download),
                        resume: self.createResumeHandler(forDownload: download),
                        suspend: self.createSuspendHandler(forDownload: download)
                    )
                    resolver.fulfill(manager)
                }.catch { _ in }
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
