//
//  RecordDownloader+URLSessionDownloadDelegate.swift
//  Podcasts
//
//  Created by user166334 on 7/16/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

extension RecordDownloader: URLSessionDownloadDelegate {
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
                if activeDownloads.isEmpty { resignSchedulerClient?() }
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
            if let download = activeDownloads.removeValue(forKey: url) {
                // must be correct
                if activeDownloads.isEmpty { resignSchedulerClient?() }
                download.handler(.failure(.init(.cancelled)))
            }
        }
    }}
