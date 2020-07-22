//
//  RecordDownloader+URLSessionSchedulable.swift
//  Podcasts
//
//  Created by user166334 on 7/16/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import PromiseKit

extension EpisodeRecordDownloader: URLSessionSchedulable {
    var sessionId: String { backgroundSessionIdentifier }
    // before app move to suspended
    func transitToBackgroundSessionExecution() { 
        assert(Thread.isMainThread, "\(#function) should call on main thread")
        print(#function)
        
        print("\(state.downloads.count) tasks are about to move to background")
        self.state.downloads.forEach { download in
            let downloadUrl = download.episode.streamUrl
            if let task = self.foregroundTasks.removeValue(forKey: downloadUrl) {
                task.cancel { [weak self] resumeDataOrNil in
                    guard let self = self else { return }
                    
                    let task: URLSessionDownloadTask
                    if let resumeData = resumeDataOrNil {
                        task = self.backgroundSession.downloadTask(withResumeData: resumeData)
                    } else {
                        task = self.backgroundSession.downloadTask(with: downloadUrl)
                    }
                    task.taskDescription = download.episode.serialized
                    task.resume()
                }
            }
        }
    }
    // when app become active
    func transitToForegroundSessionExecution() {
        assert(Thread.isMainThread, "\(#function) should call on main thread")
        print(#function)
        // recover session to foreground
        backgroundSession.getAllTasks { [weak self] tasks in
            guard let self = self else { return }
            
            print("\(tasks.count) tasks are about to move to foreground")
            let promises = tasks
                .compactMap { $0 as? URLSessionDownloadTask }
                .map { downloadTask -> Promise<Episode?> in
                    Promise { resolver in
                        downloadTask.cancel { [weak self] resumeDataOrNil in
                            DispatchQueue.main.async { [weak self] in
                                guard let self = self else { return }
                                
                                if let serializedEpisode = downloadTask.taskDescription {
                                    if let episode = Episode.instantiate(withString: serializedEpisode) {
                                        let download = EpisodeDownload(episode: episode, progress: 0)
                                        let task: URLSessionDownloadTask
                                        if let resumeData = resumeDataOrNil {
                                            task = self.foregroundSession.downloadTask(withResumeData: resumeData)
                                            // need to set progress somehow
                                        } else {
                                            task = self.foregroundSession.downloadTask(with: episode.streamUrl)
                                        }
                                        
                                        task.resume()
                                        self.state.downloads.append(download)
                                        resolver.fulfill(episode)
                                    }
                                } else {
                                    resolver.fulfill(nil)
                                }
                            }
                        }
                    }
                }
            
            when(resolved: promises).done { results in
                let episodes = results.compactMap { res -> Episode? in
                    if case Result<Episode?>.fulfilled(let episode) = res {
                        return episode
                    }
                    
                    return nil
                }
                
                if !episodes.isEmpty {
                    self.emit(.recovered(episodes, self.state))
                }
            }
        }
    }
}

private extension Episode {
    var serialized: String {
        let data = try! JSONEncoder().encode(self)
        return String(data: data, encoding: .utf8)!
    }
    
    static func instantiate(withString string: String) -> Episode? {
        let data = Data(string.utf8)
        return try? JSONDecoder().decode(self, from: data)
    }
}
