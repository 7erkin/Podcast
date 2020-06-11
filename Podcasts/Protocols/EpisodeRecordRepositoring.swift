//
//  EpisodeRecordDownloading.swift
//  Podcasts
//
//  Created by user166334 on 6/5/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

typealias DownloadingEpisode = (Episode, Double)

enum EpisodeRecordRepositoryEvent {
    case initial([EpisodeRecordDescriptor], [DownloadingEpisode])
    case downloadingStarted(Episode, [DownloadingEpisode])
    case downloadingCancelled(Episode, [DownloadingEpisode])
    case downloadingFulfilled(Episode, [DownloadingEpisode], [EpisodeRecordDescriptor])
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
