//
//  EpisodeRecordDownloading.swift
//  Podcasts
//
//  Created by user166334 on 6/5/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

struct EpisodeRecordRepositoryState {
    var activeDownloads: [EpisodeDownload] = []
    var localDownloads: [EpisodeRecordDescriptor] = []
}

struct 
enum EpisodeRecordRepositoryEvent {
    // 1. stored episode records 2. downloading episodes with downloading progress
    case initial(EpisodeRecordRepositoryState)
    // 1. episode for download 2. next state of downloading episodes with downloading progress
    case downloadStarted(Episode, Podcast, EpisodeRecordRepositoryState)
    case downloadCancelled(Episode, Podcast, EpisodeRecordRepositoryState)
    case download(EpisodeRecordRepositoryState)
    // 1. episode which has been downloaded
    // 2. next state of downloading episodes
    // 3. next state of stored episode records
    case downloadFulfilled(Episode, Podcast, EpisodeRecordRepositoryState)
    case removed(EpisodeRecordDescriptor, EpisodeRecordRepositoryState)
}

protocol EpisodeRecordRepositoring: class {
    func remove(recordDescriptor: EpisodeRecordDescriptor)
    func downloadRecord(ofEpisode episode: Episode, ofPodcast podcast: Podcast)
    func cancelDownloadRecord(ofEpisode episode: Episode)
    func subscribe(
        _ subscriber: @escaping (EpisodeRecordRepositoryEvent) -> Void
    ) -> Subscription
}

//extension Array where Element == DownloadEpisode {
//    func firstIndex(where episode: Episode) -> Int? {
//        return self.firstIndex(where: { $0.episode == episode })
//    }
//    
//    @discardableResult
//    mutating func remove(where episode: Episode) -> DownloadEpisode? {
//        if let index: Int = firstIndex(where: episode) {
//            return self.remove(at: index)
//        }
//        
//        return nil
//    }
//}
