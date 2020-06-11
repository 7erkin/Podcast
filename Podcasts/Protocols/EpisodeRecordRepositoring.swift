//
//  EpisodeRecordDownloading.swift
//  Podcasts
//
//  Created by user166334 on 6/5/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

enum EpisodeRecordRepositoryEvent {
    // 1. stored episode records 2. downloading episodes with downloading progress
    case initial([EpisodeRecordDescriptor], OrderedDictionary<Episode, Double>)
    // 1. episode for download 2. next state of downloading episodes with downloading progress
    case downloadingStarted(Episode, OrderedDictionary<Episode, Double>)
    case downloadingCancelled(Episode, OrderedDictionary<Episode, Double>)
    // 1. episode which has been downloaded
    // 2. next state of downloading episodes
    // 3. next state of stored episode records
    case downloadingFulfilled(Episode, OrderedDictionary<Episode, Double>, [EpisodeRecordDescriptor])
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
