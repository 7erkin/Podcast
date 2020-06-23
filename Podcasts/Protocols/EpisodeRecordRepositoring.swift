//
//  EpisodeRecordDownloading.swift
//  Podcasts
//
//  Created by user166334 on 6/5/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

struct CurrentDownloadEpisode {
    let episode: Episode
    let podcast: Podcast
    var progress: Double
    init(episode: Episode, podcast: Podcast) {
        self.episode = episode
        self.podcast = podcast
        progress = 0
    }
}

enum EpisodeRecordRepositoryEvent {
    // 1. stored episode records 2. downloading episodes with downloading progress
    case initial([EpisodeRecordDescriptor], [CurrentDownloadEpisode])
    // 1. episode for download 2. next state of downloading episodes with downloading progress
    case downloadingStarted(Episode, [CurrentDownloadEpisode])
    case downloadingCancelled(Episode, [CurrentDownloadEpisode])
    // 1. episode which has been downloaded
    // 2. next state of downloading episodes
    // 3. next state of stored episode records
    case downloadingFulfilled(Episode, [CurrentDownloadEpisode], [EpisodeRecordDescriptor])
    case removed(EpisodeRecordDescriptor, [EpisodeRecordDescriptor])
}

protocol EpisodeRecordRepositoring: class {
    func remove(recordDescriptor: EpisodeRecordDescriptor)
    func downloadRecord(ofEpisode episode: Episode, ofPodcast podcast: Podcast)
    func cancelDownloadingRecord(ofEpisode episode: Episode)
    func subscribe(
        _ subscriber: @escaping (EpisodeRecordRepositoryEvent) -> Void
    ) -> Subscription
}
