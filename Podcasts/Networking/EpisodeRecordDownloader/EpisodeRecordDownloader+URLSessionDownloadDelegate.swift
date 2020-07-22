//
//  RecordDownloader+URLSessionDownloadDelegate.swift
//  Podcasts
//
//  Created by user166334 on 7/16/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

extension EpisodeRecordDownloader: URLSessionDownloadDelegate {
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
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    if let index = self.state.downloads.firstIndex(where: { $0.episode.streamUrl == url }) {
                        let download = self.state.downloads.remove(at: index)
                        if self.state.downloads.isEmpty {
                            self.scheduler.remove(client: self)
                        }
                        
                        self.emit(.fulfilled(download.episode, temporaryUrl, self.state))
                    }
                }
            } catch { }
        }
    }
    
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        print(#function)
        if let url = downloadTask.originalRequest?.url {
            let progress = Double((100 * totalBytesWritten) / totalBytesExpectedToWrite) / 100
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                if let index = self.state.downloads.firstIndex(where: { $0.episode.streamUrl == url }) {
                    self.state.downloads[index].progress = progress
                    self.emit(.progressUpdated(self.state.downloads[index].episode, self.state))
                }
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print(#function)
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        
    }
}
